import 'package:flutter/material.dart';
import 'package:kawiarnia/screens/cart/cart_manager.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Kolorystyka
  final Color _bgColor = const Color(0xFFFCF7F3); 
  Color get _primaryBrown => Theme.of(context).colorScheme.primary; 
  final Color _cardBgColor = const Color(0xFFF6EFEA); 

  // Stan wyboru
  late String _selectedDate;
  String _selectedTime = '';

  // Zmienne z prawdziwymi datami
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
    DateTime(2026, 5, 1),   // Święto Pracy
    DateTime(2026, 5, 3),   // Święto Konstytucji 3 Maja
    DateTime(2026, 11, 1),  // Wszystkich Świętych
    DateTime(2026, 11, 11), // Święto Niepodległości
    DateTime(2026, 12, 25), // Boże Narodzenie
    DateTime(2026, 12, 26), // Drugi dzień świąt
  ];

  @override
  void initState() {
    super.initState();
    _todayDate = DateTime.now();
    _tomorrowDate = _todayDate.add(const Duration(days: 1));
    
    _todayStr = _formatDate(_todayDate, 'Today');
    _tomorrowStr = _formatDate(_tomorrowDate, 'Tomorrow');
    
    // Inteligentne ustawianie domyślnego dnia
    if (!_isDayOff(_todayDate)) {
      _selectedDate = _todayStr;
    } else if (!_isDayOff(_tomorrowDate)) {
      _selectedDate = _tomorrowStr;
    } else {
      _selectedDate = _formatDate(_getInitialCalendarDate(_todayDate), 'Custom'); 
    }

    _selectedTime = _getFirstAvailableTime();

    // Jeśli dzisiaj minęły już wszystkie godziny pracujące, automatycznie przeskocz na jutro
    if (_selectedTime.isEmpty && _selectedDate == _todayStr) {
      if (!_isDayOff(_tomorrowDate)) {
        _selectedDate = _tomorrowStr;
        _selectedTime = _timeSlots.first;
      }
    }
  }

  // --- LOGIKA DAT I GODZIN ---

  bool _isDayOff(DateTime date) {
    DateTime now = DateTime.now();

    // 1. Sprawdzamy, czy sprawdzana data to "dzisiaj" i czy minęły już godziny pracy
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      // Wyciągamy godzinę startu z ostatniego elementu na liście (np. '18' z '18:00 - 19:00')
      int lastSlotStartHour = int.parse(_timeSlots.last.substring(0, 2));
      
      if (now.hour >= lastSlotStartHour) {
        return true; // Dzisiaj jest już "zamknięte", traktujemy jak dzień wolny
      }
    }

    // 2. Sprawdzamy niedziele
    if (date.weekday == DateTime.sunday) return true;

    // 3. Sprawdzamy listę świąt
    for (DateTime holiday in _holidays) {
      if (date.year == holiday.year && date.month == holiday.month && date.day == holiday.day) {
        return true;
      }
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
        if (startHour > currentHour) {
          return slot;
        }
      }
      return ''; // Jeśli brak dostępnych godzin dzisiaj
    }
    return _timeSlots.first; // W inny dzień zawsze pierwsza godzina z listy
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

  DateTime _getInitialCalendarDate(DateTime now) {
    DateTime date = now.add(const Duration(days: 2));
    while (_isDayOff(date)) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  Future<void> _pickCustomDate() async {
    DateTime now = DateTime.now();
    
    // Zabezpieczenie: jeśli dzisiaj jest już zamknięte, kalendarz zaczyna się od jutra
    DateTime firstAllowedDate = _isDayOff(now) ? now.add(const Duration(days: 1)) : now;

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _getInitialCalendarDate(now), 
      firstDate: firstAllowedDate, // Używamy naszej nowej, bezpiecznej daty
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
      _onDateChanged(_formatDate(picked, 'Custom'));
    }
  }

  // --- MATEMATYKA ZAMÓWIENIA ---
  double get subtotal => CartManager.items.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  double get shippingFee => CartManager.items.isEmpty ? 0.0 : 8.50;
  double get estimatedTax => subtotal * 0.05;
  double get totalAmount => subtotal + shippingFee + estimatedTax;

  // --- WIDOK GŁÓWNY ---
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
            Text('UniBrew', style: TextStyle(color: _primaryBrown, fontWeight: FontWeight.bold, fontSize: 20, fontStyle: FontStyle.italic)),
            const SizedBox(width: 8),
            const Text('CHECKOUT', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(radius: 16, backgroundImage: const AssetImage('assets/profile_avatar.png'), backgroundColor: Colors.grey.shade300),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Review\nOrder', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: _primaryBrown, height: 1.1)),
            const SizedBox(height: 12),
            Text('One final check before your sensory\nexperience arrives.', style: TextStyle(fontSize: 16, color: Colors.grey.shade800, height: 1.4)),
            const SizedBox(height: 30),

            // ADRES DOSTAWY
            _buildSectionCard(
              icon: Icons.local_shipping, title: 'Delivery Address', actionText: 'EDIT', onActionTap: () {},
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Julianna Thorne', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text('882 Aromatic Lane, Suite 4\nPortland, OR 97201', style: TextStyle(color: Colors.grey.shade700, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // CZAS DOSTAWY
            _buildSectionCard(
              icon: Icons.access_time_filled, title: 'Delivery Time', actionText: 'RESET',
              onActionTap: () {
                if (!_isDayOff(_todayDate)) {
                  _onDateChanged(_todayStr);
                  if (_selectedTime.isEmpty && !_isDayOff(_tomorrowDate)) {
                    _onDateChanged(_tomorrowStr); 
                  }
                }
              },
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

            // PŁATNOŚĆ
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

            // KOSZYK
            const Text('YOUR SELECTION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.black54)),
            const SizedBox(height: 16),
            if (CartManager.items.isEmpty)
              Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Center(child: Text('Twoje zamówienie jest puste.', style: TextStyle(color: Colors.grey.shade600, fontSize: 16))))
            else
              ...CartManager.items.map((item) => _buildCartItem(item['name'], item['subtitle'], item['price'], item['quantity'], item['image'])),
            const SizedBox(height: 24),

            // PODSUMOWANIE
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: _cardBgColor, borderRadius: BorderRadius.circular(30)),
              child: Column(
                children: [
                  _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}', isBold: false),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Shipping (Express)', '\$${shippingFee.toStringAsFixed(2)}', isBold: false),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Estimated Tax', '\$${estimatedTax.toStringAsFixed(2)}', isBold: false),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: Divider(color: Colors.black12, thickness: 1)),
                  _buildSummaryRow('Total Amount', '\$${totalAmount.toStringAsFixed(2)}', isBold: true, valueSize: 24, valueColor: _primaryBrown),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // PRZYCISK FINALIZACJI
            SizedBox(
              width: double.infinity, height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _primaryBrown, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 5),
                onPressed: (CartManager.items.isEmpty || _selectedTime.isEmpty) ? null : () {
                  // Czyszczenie koszyka i przejście do animacji sukcesu
                  setState(() {
                    CartManager.items.clear();
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
                  );
                },
                child: const Text('Place Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            const Center(child: Text('SECURE ENCRYPTED TRANSACTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2))),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- FUNKCJE WIDŻETÓW ---

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
            decoration: isOff ? TextDecoration.lineThrough : null, // Przekreśla zamknięte dni
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
              decoration: isPast ? TextDecoration.lineThrough : null, // Przekreśla minione godziny
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
          ClipRRect(borderRadius: BorderRadius.circular(16), child: Container(width: 70, height: 70, color: const Color(0xFF3E2723), child: Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.coffee, color: Colors.white54)))),
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