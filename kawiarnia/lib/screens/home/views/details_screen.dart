import 'package:cart_item_repository/cart_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kawiarnia/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:kawiarnia/screens/cart/blocks/cart_bloc/cart_bloc.dart';

// ignore: implementation_imports
import 'package:product_repository/src/models/product.dart';

class DetailsScreen extends StatefulWidget {
  final Product product;
  const DetailsScreen(this.product, {super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int _quantity = 1;
  String _selectedSize = 'Small';
  String _selectedSugar = 'No';
  late String _selectedMilk; 

  @override
  void initState() {
    super.initState();
    if (widget.product.milk == false) {
      _selectedMilk = 'None';
    } else {
      _selectedMilk = 'Whole';
    }
  }

  final Color _bgColor = const Color(0xFFFCF7F3);
  Color get _primaryBrown => Theme.of(context).colorScheme.primary;
  final Color _cardBgColor = const Color(0xFFF6EFEA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _primaryBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Clockwork Coffee',
          style: TextStyle(
            color: _primaryBrown,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. DUŻE ZDJĘCIE Z ZAOKRĄGLONYMI ROGAMI
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Container(
                width: double.infinity,
                height: 320,
                color: const Color(0xFF3E2723),
                child: Image.network(
                  widget.product.link,
                  //fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.coffee,
                    size: 60,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. TYTUŁ I CENA BAZOWA
            Text(
              widget.product.product,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${widget.product.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _primaryBrown,
              ),
            ),
            const SizedBox(height: 24),

            // 3. OPIS
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _cardBgColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description_outlined, color: _primaryBrown, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'The Experience',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.product.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 4. CUP SIZE
            _buildSectionTitle('CUP SIZE'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildOptionButton('Small', _selectedSize == 'Small', () => setState(() => _selectedSize = 'Small')),
                _buildOptionButton('Medium', _selectedSize == 'Medium', () => setState(() => _selectedSize = 'Medium')),
                _buildOptionButton('Large', _selectedSize == 'Large', () => setState(() => _selectedSize = 'Large')),
              ],
            ),
            const SizedBox(height: 30),

            // 5. SUGAR LEVEL
            _buildSectionTitle('SUGAR LEVEL'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildOptionButton('No', _selectedSugar == 'No', () => setState(() => _selectedSugar = 'No')),
                _buildOptionButton('Normal', _selectedSugar == 'Normal', () => setState(() => _selectedSugar = 'Normal')),
                _buildOptionButton('Medium', _selectedSugar == 'Medium', () => setState(() => _selectedSugar = 'Medium')),
              ],
            ),
            const SizedBox(height: 30),

            // 6. MILK TYPE (Tylko jeśli produkt ma opcję mleka)
            if (widget.product.milk) ...[
              _buildSectionTitle('MILK TYPE'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildOptionButton('Whole', _selectedMilk == 'Whole', () => setState(() => _selectedMilk = 'Whole')),
                  _buildOptionButton('Oat', _selectedMilk == 'Oat', () => setState(() => _selectedMilk = 'Oat')),
                  _buildOptionButton('Soy', _selectedMilk == 'Soy', () => setState(() => _selectedMilk = 'Soy')),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ],
        ),
      ),

      // 7. PŁYWAJĄCY DOLNY PASEK
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: _bgColor,
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: _bgColor.withOpacity(0.9),
              blurRadius: 20,
              offset: const Offset(0, -20),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  // ignore: deprecated_member_use
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 20),
                    color: _quantity > 1 ? Colors.black87 : Colors.grey,
                    onPressed: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                  ),
                  SizedBox(
                    width: 20,
                    child: Text(
                      '$_quantity',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    color: Colors.black87,
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Przycisk "Add To Cart"
            Expanded(
              child: SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBrown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    // 1. POBIERAMY STATUS LOGOWANIA I ID UŻYTKOWNIKA
                    final authState = context.read<AuthenticationBloc>().state;
                    
                    if (authState.status != AuthenticationStatus.authenticated) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Musisz być zalogowany, aby dodać do koszyka!')),
                      );
                      return;
                    }

                    final String userId = authState.user!.userId;
                    final newItem = CartItem(
                      cartId: '',
                      productId: widget.product.productId, 
                      product: widget.product.product,
                      link: widget.product.link,
                      price: widget.product.price,
                      quantity: _quantity,
                      size: _selectedSize,
                      sugar: _selectedSugar,
                      milk: _selectedMilk, 
                    );
                    context.read<CartBloc>().add(AddProductToCart(userId, newItem));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Dodano $_quantity ${widget.product.product} do koszyka!'),
                        backgroundColor: _primaryBrown,
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Add To Cart',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '\$${(widget.product.price * _quantity).toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pomocnicza: Tytuł sekcji (CUP SIZE, SUGAR LEVEL, MILK TYPE)
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: Colors.black54,
      ),
    );
  }

  // Pomocnicza: Przycisk wyboru
  Widget _buildOptionButton(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected ? _primaryBrown : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? _primaryBrown : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}