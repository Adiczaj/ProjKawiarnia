import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kawiarnia/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:kawiarnia/screens/cart/blocks/cart_bloc/cart_bloc.dart';
import 'package:kawiarnia/screens/cart/blocks/order_bloc/order_bloc.dart';


import 'package:kawiarnia/screens/cart/views/checkout_screen.dart';
import 'package:order_repository/order_repository.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final double deliveryFee = 0.00;

  @override
  void initState() {
    super.initState();
    // Załaduj koszyk gdy ekran się załaduje
    final authState = context.read<AuthenticationBloc>().state;
    if (authState.status == AuthenticationStatus.authenticated) {
      final userId = authState.user!.userId;
      context.read<CartBloc>().add(LoadCart(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthenticationBloc>().state;
    final String userId = (authState.status == AuthenticationStatus.authenticated) 
        ? authState.user!.userId
        : '';

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
              'Clockwork Coffee',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),

      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading || state is CartInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CartFailure) {
            return Center(child: Text('An error occurred: ${state.errorMessage}'));
          }

          if (state is CartLoaded) {
            final items = state.items;
            final subtotal = state.totalPrice;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Cart',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Review your order',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // Sprawdzamy, czy koszyk jest pusty
                  if (items.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Column(
                          children: [
                            Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'Your cart is empty',
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
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return _buildCartItem(context, items[index], userId);
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
                              hintText: 'Promo Code',
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
                          // Logika kodu promocyjnego
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3CFC6),
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          minimumSize: const Size(100, 50),
                        ),
                        child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}', isBold: false),
                        const SizedBox(height: 12),
                        _buildSummaryRow('Shipping', deliveryFee == 0 ? 'FREE' : '\$${deliveryFee.toStringAsFixed(2)}', isBold: false, valueColor: Theme.of(context).colorScheme.primary),
                        const Divider(height: 30, thickness: 1),
                        _buildSummaryRow('Total', '\$${(subtotal + deliveryFee).toStringAsFixed(2)}', isBold: true, fontSize: 22),
                        const SizedBox(height: 20),
                        
                        // Przycisk "Przejdź do kasy"
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: items.isEmpty 
                              ? null
                              : () {
                                  final cartBloc = context.read<CartBloc>(); 
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MultiBlocProvider(
                                    providers: [
                                      BlocProvider.value(
                                        value: cartBloc,
                                      ),
                                      BlocProvider<OrderBloc>(
                                        create: (context) => OrderBloc(FirebaseOrderRepo()),
                                      ),
                                    ],
                                    child: const CheckoutScreen(),
                                  ),
                                ),
                              );
                               },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              disabledBackgroundColor: Colors.grey.shade400,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: items.isEmpty ? 0 : 5,
                            ),
                            child: const Text(
                              'Proceed to Checkout',
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
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, dynamic item, String userId) {
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
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Colors.black87,
              width: 80,
              height: 80,
              child: Image.network(
                item.link,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.coffee, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Size: ${item.size}, Milk: ${item.milk}, Sugar: ${item.sugar}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
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
                              if (item.quantity > 1) {
                                context.read<CartBloc>().add(
                                  UpdateItemQuantity(userId, item.cartId, item.quantity - 1)
                                );
                              } else {
                                context.read<CartBloc>().add(
                                  RemoveItemFromCart(userId, item.cartId)
                                );
                              }
                            },
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: () {
                              context.read<CartBloc>().add(
                                UpdateItemQuantity(userId, item.cartId, item.quantity + 1)
                              );
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