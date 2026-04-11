import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kawiarnia/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:order_repository/order_repository.dart' as order_repo;

class OrderItem {
  final String imageUrl;
  final String name;
  final String description;
  final double price;

  const OrderItem({
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.price,
  });
}

class Order {
  final String orderReference;
  final String status;
  final String deliveryMethod;
  final List<OrderItem> items;
  final double totalAmount;

  const Order({
    required this.orderReference,
    required this.status,
    required this.deliveryMethod,
    required this.items,
    required this.totalAmount,
  });

  bool get isOnTheWay => status.toUpperCase() == 'BREWING' || status.toUpperCase() == 'ON THE WAY';

  bool get isDelivery {
    final method = deliveryMethod.trim().toLowerCase();
    return method.contains('delivery');
  }

  bool get canContactCourier => isOnTheWay && isDelivery;
}

OrderItem mapItem(order_repo.Items item) {
  return OrderItem(
    imageUrl: item.link,
    name: item.product,
    description: 'Size: ${item.size}, Sugar: ${item.sugar}, Milk: ${item.milk}',
    price: item.price,
  );
}

Order mapOrder(order_repo.Order order) {
  return Order(
    orderReference: order.orderId,
    status: order.status,
    deliveryMethod: order.deliveryMethod,
    items: order.items.map(mapItem).toList(),
    totalAmount: order.totalAmount,
  );
}

class ActiveOrdersScreen extends StatefulWidget {
  const ActiveOrdersScreen({super.key});

  @override
  State<ActiveOrdersScreen> createState() => _ActiveOrdersScreenState();
}

class _ActiveOrdersScreenState extends State<ActiveOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    // Paleta kolorów
    final Color darkBrownColor = Theme.of(context).colorScheme.primary;
    const Color lightBrownColor = Color(0xFF9E8B83);
    const Color brewingLabelColor = Color(0xFFFBE4D7);
    const Color receivedLabelColor = Color(0xFFEFEFEF);
    final Color activeBtnColor = Theme.of(context).colorScheme.primary;
    const Color inactiveBtnColor = Color(0xFFEFEFEF);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: darkBrownColor),
          onPressed: () {
            // Funkcja cofająca
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Current Orders',
          style: TextStyle(
            color: darkBrownColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, authState) {
          if (authState.status != AuthenticationStatus.authenticated || authState.user == null) {
            return const Center(child: Text('Not authenticated'));
          }
          final userId = authState.user!.userId;
          return StreamBuilder<List<order_repo.Order>>(
            stream: order_repo.FirebaseOrderRepo().getOrders(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final repoOrders = snapshot.data ?? [];
              final orders = repoOrders.map(mapOrder).toList();
              if (orders.isEmpty) {
                return const Center(child: Text('No active orders'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(24.0),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return OrderCard(
                    order: order,
                    darkBrownColor: darkBrownColor,
                    lightBrownColor: lightBrownColor,
                    brewingLabelColor: brewingLabelColor,
                    receivedLabelColor: receivedLabelColor,
                    activeBtnColor: activeBtnColor,
                    inactiveBtnColor: inactiveBtnColor,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// 4. Widżet karty dla pojedynczego zamówienia
class OrderCard extends StatelessWidget {
  final Order order;
  final Color darkBrownColor;
  final Color lightBrownColor;
  final Color brewingLabelColor;
  final Color receivedLabelColor;
  final Color activeBtnColor;
  final Color inactiveBtnColor;

  const OrderCard({
    super.key,
    required this.order,
    required this.darkBrownColor,
    required this.lightBrownColor,
    required this.brewingLabelColor,
    required this.receivedLabelColor,
    required this.activeBtnColor,
    required this.inactiveBtnColor,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = order.isOnTheWay ? brewingLabelColor : receivedLabelColor;
    final statusTextColor = order.isOnTheWay ? darkBrownColor : Colors.grey[700]!;

    return Card(
      elevation: 4,
      // ignore: deprecated_member_use
      shadowColor: Colors.black.withOpacity(0.15),
      margin: const EdgeInsets.only(bottom: 24.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nagłówek karty (Referencja i status)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORDER REFERENCE',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.5,
                        color: lightBrownColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.orderReference,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: darkBrownColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      color: statusTextColor,
                      fontSize: 10,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Lista produktów (zagnieżdżona w Column)
            Column(
              children: order.items
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: OrderItemRow(
                          item: item,
                          darkBrownColor: darkBrownColor,
                          lightBrownColor: lightBrownColor,
                        ),
                      ))
                  .toList(),
            ),

            // Podziałka
            const Divider(height: 1),
            const SizedBox(height: 24),

            // Dół karty (Całkowita kwota i przycisk)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL AMOUNT',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.5,
                        color: lightBrownColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: darkBrownColor,
                      ),
                    ),
                  ],
                ),
                // 5. Logika przycisku "Contact Courier"
                SizedBox(
                  width: 170, // Szerokość przycisku
                  child: ElevatedButton(
                    onPressed: order.canContactCourier
                        ? () {
                            // Tutaj dodaj logikę skontaktowania się z kurierem
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Łączę z kurierem... 📞')),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: activeBtnColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: inactiveBtnColor,
                      disabledForegroundColor: Colors.grey[600],
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Contact Courier',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 6. Widżet rzędu dla pojedynczego produktu
class OrderItemRow extends StatelessWidget {
  final OrderItem item;
  final Color darkBrownColor;
  final Color lightBrownColor;

  const OrderItemRow({
    super.key,
    required this.item,
    required this.darkBrownColor,
    required this.lightBrownColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Obrazek produktu
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35), // Okrągłe
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 20),

        // Opis produktu
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: darkBrownColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.description,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: lightBrownColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),

        // Cena
        Text(
          '\$${item.price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: darkBrownColor,
          ),
        ),
      ],
    );
  }
}