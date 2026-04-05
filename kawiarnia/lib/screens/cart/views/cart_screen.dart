import 'package:flutter/material.dart';
import 'package:kawiarnia/screens/cart/cart_manager.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final double deliveryFee = 0.00; // Darmowa dostawa

  // Funkcja obliczająca sumę koszyka na podstawie globalnej listy
  double get subtotal {
    return CartManager.items.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F7),
      
      // Górny pasek
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              scale: 7.5
            ),
            const SizedBox(width: 8),
            Text(
              'UniBrew',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Twój Koszyk',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Przejrzyj swoje zamówienie',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Sprawdzamy, czy koszyk jest pusty
            if (CartManager.items.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Column(
                    children: [
                      Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Twój koszyk jest pusty',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Lista produktów w koszyku
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: CartManager.items.length,
                itemBuilder: (context, index) {
                  return _buildCartItem(index);
                },
              ),
            
            const SizedBox(height: 16),

            // Sekcja kodu promocyjnego
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Kod promocyjny',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // Logika kodu promocyjnego (np. walidacja kodu, zastosowanie rabatu)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3CFC6), // Jasnobrzoskwiniowy
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    minimumSize: const Size(100, 50),
                  ),
                  child: const Text('Zastosuj', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Podsumowanie kosztów
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Suma częściowa', '\$${subtotal.toStringAsFixed(2)}', isBold: false),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Dostawa', deliveryFee == 0 ? 'DARMOWA' : '\$${deliveryFee.toStringAsFixed(2)}', isBold: false, valueColor: Theme.of(context).colorScheme.primary),
                  const Divider(height: 30, thickness: 1),
                  _buildSummaryRow('Razem', '\$${(subtotal + deliveryFee).toStringAsFixed(2)}', isBold: true, fontSize: 22),
                  const SizedBox(height: 20),
                  
                  // Przycisk "Przejdź do kasy"
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: CartManager.items.isEmpty 
                          ? null // Wyłącza przycisk, jeśli koszyk jest pusty
                          : () {
                              // Logika płatności
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: CartManager.items.isEmpty ? 0 : 5,
                      ),
                      child: const Text(
                        'Przejdź do kasy',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Funkcja budująca pojedynczy element w koszyku
  Widget _buildCartItem(int index) {
    var item = CartManager.items[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Obrazek produktu
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Colors.black87,
              width: 80,
              height: 80,
              child: Image.asset(
                item['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.coffee, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Informacje o produkcie i przyciski
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  item['subtitle'],
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${item['price'].toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary),
                    ),
                    // Przyciski +/-
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: () {
                              setState(() {
                                if (item['quantity'] > 1) {
                                  item['quantity']--;
                                } else {
                                  CartManager.items.removeAt(index);
                                }
                              });
                            },
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          Text(
                            '${item['quantity']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: () {
                              setState(() {
                                item['quantity']++;
                              });
                            },
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Funkcja pomocnicza do budowania wierszy podsumowania
  Widget _buildSummaryRow(String title, String value, {bool isBold = false, double fontSize = 16, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.black : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}