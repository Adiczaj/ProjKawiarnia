import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kawiarnia/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:kawiarnia/screens/cart/blocks/cart_bloc/cart_bloc.dart';
import 'package:kawiarnia/screens/cart/blocks/order_bloc/order_bloc.dart';
import 'package:order_repository/order_repository.dart' as order_repository;

import 'order_success_screen.dart';
import 'edit_delivery_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final double deliveryFee;
  final double discountAmount;
  
  const CheckoutScreen({
    super.key, 
    required this.deliveryFee, 
    required this.discountAmount
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Color get _bgColor => Theme.of(context).colorScheme.surface; 
  Color get _primaryBrown => Theme.of(context).colorScheme.primary; 
  final Color _cardBgColor = const Color(0xFFF6EFEA); 

  String _addressName = 'Loading data...'; 
  String _addressStreet = 'Searching for address...';
  String _addressLabel = 'Address';

  late String _selectedDate;
  String _selectedTime = '';
  DateTime? _actualCustomDate;

  late DateTime _todayDate;
  late DateTime _tomorrowDate;
  late String _todayStr;
  late String _tomorrowStr;

  final List<String> _timeSlots = [
    '09:00 - 10:00', '10:00 - 11:00', 
    '11:00 - 12:00', '12:00 - 13:00',
    '13:00 - 14:00', '14:00 - 15:00',
    '15:00 - 16:00', '16:00 - 17:00',
    '17:00 - 18:00', '18:00 - 19:00',
  ];

  // Lista świąt, w które kawiarnia jest zamknięta
  final List<DateTime> _holidays = [
    DateTime(2026, 5, 1),   
    DateTime(2026, 5, 3),   
    DateTime(2026, 11, 1),  
    DateTime(2026, 11, 11), 
    DateTime(2026, 12, 25), 
    DateTime(2026, 12, 26), 
  ];

  @override
  void initState() {
    super.initState();
    _todayDate = DateTime.now();
    _tomorrowDate = _todayDate.add(const Duration(days: 1));
    
    _todayStr = _formatDate(_todayDate, 'Today');
    _tomorrowStr = _formatDate(_tomorrowDate, 'Tomorrow');
    
    // domyslny dzien
    if (!_isDayOff(_todayDate)) {
      _selectedDate = _todayStr;
    } else if (!_isDayOff(_tomorrowDate)) {
      _selectedDate = _tomorrowStr;
    } else {
      _selectedDate = _formatDate(_getInitialCalendarDate(_todayDate), 'Custom'); 
    }

    _selectedTime = _getFirstAvailableTime();

    if (_selectedTime.isEmpty && _selectedDate == _todayStr) {
      if (!_isDayOff(_tomorrowDate)) {
        _selectedDate = _tomorrowStr;
        _selectedTime = _timeSlots.first;
      }
    }
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authState = context.read<AuthenticationBloc>().state;
    
    if (authState.status == AuthenticationStatus.authenticated) {
      final user = authState.user!;
      final userId = user.userId;
      
      setState(() {
        _addressName = user.name; 
      });

      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        
        if (doc.exists && doc.data()!.containsKey('defaultAddress')) {
          final data = doc.data()!['defaultAddress'] as Map<String, dynamic>;
          
          setState(() {
            _addressLabel = data['label'] ?? 'Home';
            
            String street = data['street'] ?? '';
            String apt = (data['apartment']?.isNotEmpty ?? false) ? ', ${data['apartment']}' : '';
            String city = data['city'] ?? '';
            String postal = data['postalCode'] ?? '';
            
            _addressStreet = "$street$apt\n$postal $city";
          });
        } else {
           setState(() {
             _addressStreet = "No saved address.\nClick EDIT to add one.";
             _addressLabel = "New Address";
           });
        }
      } catch (e) {
        setState(() {
          _addressStreet = "Error loading address.\nClick EDIT to try again.";
          _addressLabel = "Error";
        });
      }
    }
  }

  bool _isDayOff(DateTime date) {
    DateTime now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      int lastSlotStartHour = int.parse(_timeSlots.last.substring(0, 2));
      if (now.hour >= lastSlotStartHour) {
        return true; 
      }
    }
    if (date.weekday == DateTime.sunday) return true;
    for (DateTime holiday in _holidays) {
      if (date.year == holiday.year && date.month == holiday.month && date.day == holiday.day) return true;
    }
    return false;
  }

  String _formatDate(DateTime date, String prefix) {
    const List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '$prefix,\n${date.day} ${months[date.month - 1]}';
  }

  String _getFirstAvailableTime() {
    if (_selectedDate == _todayStr) {
      int currentHour = DateTime.now().hour;
      for (String slot in _timeSlots) {
        int startHour = int.parse(slot.substring(0, 2));
        if (startHour > currentHour) return slot;
      }
      return ''; 
    }
    return _timeSlots.first; 
  }

  void _onDateChanged(String newDate) {
    setState(() {
      _selectedDate = newDate;
      String availableTime = _getFirstAvailableTime();
      if (availableTime.isNotEmpty) {
        _selectedTime = availableTime;
      } else {
        _selectedTime = ''; 
      }
    });
  }

  void _resetDateTime() {
    setState(() {
      if (!_isDayOff(_todayDate)) {
        _selectedDate = _todayStr;
      } else if (!_isDayOff(_tomorrowDate)) {
        _selectedDate = _tomorrowStr;
      } else {
        _selectedDate = _formatDate(_getInitialCalendarDate(_todayDate), 'Custom'); 
      }

      _selectedTime = _getFirstAvailableTime();

      if (_selectedTime.isEmpty && _selectedDate == _todayStr) {
        if (!_isDayOff(_tomorrowDate)) {
          _selectedDate = _tomorrowStr;
          _selectedTime = _timeSlots.first;
        }
      }
    });
  }

  DateTime _getInitialCalendarDate(DateTime now) {
    DateTime date = now.add(const Duration(days: 2));
    while (_isDayOff(date)) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  Future<void> _pickCustomDate() async {
    DateTime now = DateTime.now();
    DateTime firstAllowedDate = _isDayOff(now) ? now.add(const Duration(days: 1)) : now;

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _getInitialCalendarDate(now), 
      firstDate: firstAllowedDate,
      lastDate: now.add(const Duration(days: 5)), 
      selectableDayPredicate: (DateTime day) => !_isDayOff(day), 
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: _primaryBrown, onPrimary: Colors.white, onSurface: Colors.black87),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _actualCustomDate = picked;
      _onDateChanged(_formatDate(picked, 'Custom'));
    }
  }

  // WIDOK GŁÓWNY
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: _primaryBrown), onPressed: () => Navigator.pop(context)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Clockwork Coffee', style: TextStyle(color: _primaryBrown, fontWeight: FontWeight.bold, fontSize: 20, fontStyle: FontStyle.italic)),
            const SizedBox(width: 8),
            const Text('CHECKOUT', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ],
        ),
        
      ),
      
      body: BlocListener<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
            );
          } else if (state is OrderSuccess) {
            Navigator.pop(context); 
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
            );
          } else if (state is OrderFailure) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
          
          if (state is CartLoading || state is CartInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CartFailure) {
            return Center(child: Text('Błąd pobierania koszyka: ${state.errorMessage}'));
          }

          if (state is CartLoaded) {
            final items = state.items;
            
            final double originalSubtotal = state.totalPrice; 
            final double totalAfterDiscount = originalSubtotal - widget.discountAmount;
            final double subtotal = totalAfterDiscount / 1.23;
            final double estimatedTax = totalAfterDiscount - subtotal;
            final double shippingFee = widget.deliveryFee;
            final double totalAmount = totalAfterDiscount + shippingFee;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Review\nOrder', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: _primaryBrown, height: 1.1)),
                  const SizedBox(height: 12),
                  Text('One final check before your sensory\nexperience arrives.', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface, height: 1.4)),
                  const SizedBox(height: 30),

                  _buildSectionCard(
                    icon: Icons.local_shipping, 
                    title: 'Delivery Address', 
                    actionText: 'EDIT', 
                    onActionTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DeliveryAddressScreen(), 
                        ),
                      );

                      if (result != null && result is Map<String, String>) {
                        setState(() {
                          _addressLabel = result['label'] ?? 'Home';
                          
                          String apt = result['apartment']!.isNotEmpty ? ', ${result['apartment']}' : '';
                          _addressStreet = "${result['street']}$apt\n${result['city']}, ${result['postalCode']}";
                        });
                      }
                    },
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_addressName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(_addressStreet, style: TextStyle(color: Colors.grey.shade700, height: 1.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSectionCard(
                    icon: Icons.access_time_filled, title: 'Delivery Time', actionText: 'RESET',
                    onActionTap: _resetDateTime,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildDatePill(_todayStr, _todayDate),
                              const SizedBox(width: 8),
                              _buildDatePill(_tomorrowStr, _tomorrowDate),
                              const SizedBox(width: 8),
                              _buildSelectDatePill(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _timeSlots.map((time) => _buildTimePill(time)).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSectionCard(
                    icon: Icons.payments, title: 'Payment Method', actionText: 'CHANGE', onActionTap: () {},
                    content: Row(
                      children: [
                        Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.apple, color: Colors.black, size: 20)),
                        const SizedBox(width: 12),
                        const Text('Apple Pay (•••• 9012)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text('YOUR SELECTION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.black54)),
                  const SizedBox(height: 16),
                  
                    ...items.map((item) => _buildCartItem(
                      item.product, 
                      'Rozmiar: ${item.size}, Mleko: ${item.milk}, Cukier: ${item.sugar}', 
                      item.price, 
                      item.quantity, 
                      item.link
                    )),
                    
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: _cardBgColor, borderRadius: BorderRadius.circular(30)),
                    child: Column(
                      children: [
                        _buildSummaryRow('Subtotal', '\$${originalSubtotal.toStringAsFixed(2)}', isBold: false),
      
                        if (widget.discountAmount > 0) ...[
                          const SizedBox(height: 12),
                        _buildSummaryRow('Discount', '-\$${widget.discountAmount.toStringAsFixed(2)}', isBold: false, valueColor: _primaryBrown),
                        ],
      
                        const SizedBox(height: 12),
      
                        _buildSummaryRow(
                          'Shipping (Express)', 
                          shippingFee == 0.0 ? 'FREE' : '\$${shippingFee.toStringAsFixed(2)}', 
                          isBold: shippingFee == 0.0,
                          valueColor: shippingFee == 0.0 ? _primaryBrown : null,
                        ),
      
                        const SizedBox(height: 12),
                        _buildSummaryRow('Estimated Tax', '\$${estimatedTax.toStringAsFixed(2)}', isBold: false),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: Divider(color: Colors.black12, thickness: 1)),
                        _buildSummaryRow('Total Amount', '\$${totalAmount.toStringAsFixed(2)}', isBold: true, valueSize: 24, valueColor: _primaryBrown),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity, height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: _primaryBrown, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 5),
                      onPressed: (items.isEmpty || _selectedTime.isEmpty) ? null : () {
                       final authState = context.read<AuthenticationBloc>().state;
                          final String userId = (authState.status == AuthenticationStatus.authenticated) 
                              ? authState.user!.userId 
                              : '';
                          final List<order_repository.Items> orderItems = items.map((item) => order_repository.Items(
                            productId: item.productId, 
                            product: item.product,
                            link: item.link,
                            price: item.price,
                            quantity: item.quantity,
                            size: item.size,
                            sugar: item.sugar,
                            milk: item.milk,
                          )).toList();

                          DateTime actualDeliveryDate = _todayDate;
                          if (_selectedDate == _tomorrowStr) {
                            actualDeliveryDate = _tomorrowDate;
                          } else if (_selectedDate != _todayStr) {
                            actualDeliveryDate = _actualCustomDate ?? DateTime.now().add(const Duration(days: 2));
                          }

                          final order = order_repository.Order(
                            orderId: '',
                            userId: userId,
                            deliveryAddress: '$_addressLabel: $_addressStreet',
                            totalAmount: totalAmount,
                            createdAt: DateTime.now(),
                            deliveryDate: actualDeliveryDate, 
                            deliveryMethod: 'Delivery', 
                            deliverySlot: _selectedTime, 
                            status: 'Received', 
                            items: orderItems,
                          );

                          context.read<OrderBloc>().add(SubmitOrder(userId, order));
                      },
                      child: const Text('Place Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(child: Text('SECURE ENCRYPTED TRANSACTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2))),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      )
    );
  }


  Widget _buildSectionCard({required IconData icon, required String title, required String actionText, required VoidCallback onActionTap, required Widget content}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: _cardBgColor, borderRadius: BorderRadius.circular(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: _primaryBrown),
              GestureDetector(onTap: onActionTap, child: Text(actionText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _primaryBrown, letterSpacing: 1.0))),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildDatePill(String text, DateTime actualDate) {
    bool isOff = _isDayOff(actualDate); 
    bool isSelected = _selectedDate == text;

    return GestureDetector(
      onTap: isOff ? null : () {
        _onDateChanged(text);
        if (_selectedTime.isEmpty && !_isDayOff(_tomorrowDate)) {
          _onDateChanged(_tomorrowStr); 
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isOff ? Colors.grey.shade200 : (isSelected ? _primaryBrown : Colors.white),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isOff ? Colors.transparent : (isSelected ? _primaryBrown : Colors.grey.shade300)),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isOff ? Colors.grey.shade400 : (isSelected ? Colors.white : Colors.black87),
            decoration: isOff ? TextDecoration.lineThrough : null, 
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
            height: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectDatePill() {
    bool isCustomDate = _selectedDate != _todayStr && _selectedDate != _tomorrowStr;
    return GestureDetector(
      onTap: _pickCustomDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(color: isCustomDate ? _primaryBrown : Colors.transparent, borderRadius: BorderRadius.circular(30), border: Border.all(color: isCustomDate ? _primaryBrown : Colors.grey.shade400)),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: isCustomDate ? Colors.white : _primaryBrown),
            const SizedBox(width: 8),
            Text(isCustomDate ? _selectedDate : 'Select\nDate', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, height: 1.2, color: isCustomDate ? Colors.white : Colors.black87, fontWeight: isCustomDate ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePill(String time) {
    bool isPast = false;
    if (_selectedDate == _todayStr) {
      int startHour = int.parse(time.substring(0, 2));
      if (DateTime.now().hour >= startHour) {
        isPast = true;
      }
    }

    bool isSelected = _selectedTime == time;
    double width = (MediaQuery.of(context).size.width - 48 - 48 - 12) / 2; 

    return GestureDetector(
      onTap: isPast ? null : () => setState(() => _selectedTime = time),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPast ? Colors.grey.shade200 : isSelected ? _primaryBrown : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isPast ? Colors.transparent : isSelected ? _primaryBrown : Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            time, 
            style: TextStyle(
              color: isPast ? Colors.grey.shade400 : isSelected ? Colors.white : Colors.black87, 
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              decoration: isPast ? TextDecoration.lineThrough : null, 
            )
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(String name, String subtitle, double price, int qty, String imagePath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      // ignore: deprecated_member_use
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16), 
            child: Container(
              width: 70, height: 70, color: const Color(0xFF3E2723), 
              child: Image.network(imagePath, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.coffee, color: Colors.white54))
            )
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.2)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${price.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _primaryBrown)),
              const SizedBox(height: 4),
              Text('QTY: $qty', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isBold = false, double valueSize = 16, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: isBold ? 18 : 15, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? Colors.black87 : Colors.grey.shade700)),
        Text(value, style: TextStyle(fontSize: valueSize, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: valueColor ?? Colors.black87)),
      ],
    );
  }
}