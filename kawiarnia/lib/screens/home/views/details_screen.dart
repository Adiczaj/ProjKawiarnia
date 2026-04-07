import 'package:flutter/material.dart';
import 'package:kawiarnia/screens/cart/cart_manager.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int _quantity = 1;
  final double _basePrice = 35.0;
  
  String _selectedSize = 'Medium';
  String _selectedSugar = 'No';

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
          'Sensory Brew',
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
            // 1. DUŻE ZDJĘCIE Z ZAOKRĄGLONYMI ROGAMI (Styl z makiety)
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Container(
                width: double.infinity,
                height: 320,
                color: const Color(0xFF3E2723),
                child: Image.asset(
                  'assets/caffe_latte.png',
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
            const Text(
              'Caffe Latte',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${_basePrice.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _primaryBrown,
              ),
            ),
            const SizedBox(height: 24),

            // 3. THE EXPERIENCE (Opis w karcie)
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
                    'Nasza flagowa Caffe Latte to harmonijna mieszanka podwójnego espresso specialty i aksamitnej mikropianki. Stworzona z ziaren pochodzących z etiopskich wyżyn, oferuje subtelne nuty prażonych orzechów laskowych i madagaskarskiej wanilii, kończąc się kremowym, maślanym odczuciem w ustach.',
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

            // 4. CUP SIZE (Zamiast pola tekstowego)
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
                _buildOptionButton('Normal', _selectedSugar == 'Normal', () => setState(() => _selectedSugar = 'Normal')),
                _buildOptionButton('Medium', _selectedSugar == 'Medium', () => setState(() => _selectedSugar = 'Medium')),
                _buildOptionButton('No', _selectedSugar == 'No', () => setState(() => _selectedSugar = 'No')),
              ],
            ),
            const SizedBox(height: 30),

            // 6. INFO GRID (Kalorie, Mleko, Czas, Pochodzenie - 4 kafelki)
            Row(
              children: [
                Expanded(child: _buildInfoCard(Icons.bolt, 'CALORIES', '120 kcal')),
                const SizedBox(width: 16),
                Expanded(child: _buildInfoCard(Icons.water_drop_outlined, 'MILK', 'Whole')),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildInfoCard(Icons.timer_outlined, 'PREP TIME', '4-6 mins')),
                const SizedBox(width: 16),
                Expanded(child: _buildInfoCard(Icons.public, 'ORIGIN', 'Ethiopia')),
              ],
            ),
            const SizedBox(height: 100), // Duży odstęp, aby pływający pasek nic nie zasłaniał
          ],
        ),
      ),

      // 7. PŁYWAJĄCY DOLNY PASEK Z MAKIETY (Pływający Licznik i Przycisk "Add")
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: _bgColor,
          // Dodajemy delikatny cień/gradient u góry, aby pasek oddzielał się od przewijanej treści
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
            // Kontroler ilości (Zupełnie nowa logika i wygląd ze zdjęcia)
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
            
            // Przycisk "Add To Cart" z makiety
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
                    final newItem = {
                      'name': 'Caffe Latte',
                      'subtitle': 'Size: $_selectedSize, Sugar: $_selectedSugar', 
                      'price': _basePrice,
                      'quantity': _quantity,
                      'image': 'assets/caffe_latte.png',
                    };

                    // Szukamy po nazwie I wybranym zestawie opcji (żeby Small Latte i Large Latte były osobnymi pozycjami w koszyku)
                    final existingItemIndex = CartManager.items.indexWhere(
                        (item) => item['name'] == newItem['name'] && item['subtitle'] == newItem['subtitle']);

                    setState(() {
                      if (existingItemIndex >= 0) {
                        CartManager.items[existingItemIndex]['quantity'] += _quantity;
                      } else {
                        CartManager.items.add(newItem);
                      }
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added $_quantity to cart!'),
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
                      // DYNAMICZNA CENA
                      Text(
                        '\$${(_basePrice * _quantity).toStringAsFixed(2)}',
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

  // Pomocnicza: Tytuł sekcji (CUP SIZE, SUGAR LEVEL)
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

  // Pomocnicza: Przycisk wyboru (Owalny, ze zdjęcia)
  Widget _buildOptionButton(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent, // Biały tylko gdy wybrany
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

  // Pomocnicza: Kafelki z siatki informacji (Info Grid)
  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Icon(icon, color: _primaryBrown, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}