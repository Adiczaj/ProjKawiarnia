import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kawiarnia/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:order_repository/order_repository.dart' as order_repo;

class HistoryOrderItem {
  final String imageUrl;
  final String name;
  final String description;

  const HistoryOrderItem({
    required this.imageUrl,
    required this.name,
    required this.description,
  });
}

class HistoryOrder {
  final String orderReference;
  final String date;
  final String status;
  final List<HistoryOrderItem> items;
  final double totalAmount;

  const HistoryOrder({
    required this.orderReference,
    required this.date,
    required this.status,
    required this.items,
    required this.totalAmount,
  });
}

HistoryOrderItem mapHistoryItem(order_repo.Items item) {
  return HistoryOrderItem(
    imageUrl: item.link,
    name: item.product,

    description: 'Size:${item.size}, Milk:${item.milk}, Sugar:${item.sugar}'.toUpperCase(), 
  );
}

HistoryOrder mapHistoryOrder(order_repo.Order order) {
  String formattedDate = DateFormat('MMM dd, yyyy').format(order.createdAt).toUpperCase();
  
  return HistoryOrder(
    orderReference: order.orderId,
    date: formattedDate,
    status: order.status,
    items: order.items.map(mapHistoryItem).toList(),
    totalAmount: order.totalAmount,
  );
}

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final Color darkBrownColor = Theme.of(context).colorScheme.primary;
    const Color lightBrownColor = Color(0xFF8C8A88);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: darkBrownColor),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Clockwork Coffee',
          style: TextStyle(
            color: darkBrownColor,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
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
                return Center(child: CircularProgressIndicator(color: darkBrownColor));
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              
              final repoOrders = snapshot.data ?? [];
              
              final historyRepoOrders = repoOrders.where((o) => 
                  o.status.toLowerCase() == 'delivered' || 
                  o.status.toLowerCase() == 'completed'
              ).toList();

              final orders = historyRepoOrders.map(mapHistoryOrder).toList();

              if (orders.isEmpty) {
                return const _NoOrderHistoryView();
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                itemCount: orders.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order History',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: darkBrownColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your sensory journey, archived and remembered.',
                            style: TextStyle(
                              fontSize: 15,
                              color: lightBrownColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final order = orders[index - 1];
                  
                  final bool isEven = (index - 1) % 2 == 0;
                  final Color cardBgColor = isEven ? Colors.white : const Color(0xFFF5F1EE);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: HistoryOrderCard(
                      order: order,
                      backgroundColor: cardBgColor,
                      darkBrownColor: darkBrownColor,
                    ),
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

class HistoryOrderCard extends StatelessWidget {
  final HistoryOrder order;
  final Color backgroundColor;
  final Color darkBrownColor;

  const HistoryOrderCard({
    super.key,
    required this.order,
    required this.backgroundColor,
    required this.darkBrownColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.date,
                style: const TextStyle(
                  color: Color(0xFF9E9A96),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EBE6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: darkBrownColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Text(
            order.status,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          
          Column(
            children: order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: HistoryOrderItemRow(item: item),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class HistoryOrderItemRow extends StatelessWidget {
  final HistoryOrderItem item;

  const HistoryOrderItemRow({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFFEBE6E0),
          backgroundImage: NetworkImage(item.imageUrl),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.description,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8C8A88),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NoOrderHistoryView extends StatelessWidget {
  const _NoOrderHistoryView();

  @override
  Widget build(BuildContext context) {
    final Color darkBrownColor = Theme.of(context).colorScheme.primary;
    const Color textColor = Color(0xFF8C8A88);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF4EEEE),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.local_cafe,
                size: 42,
                color: darkBrownColor,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Your journey starts here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: darkBrownColor,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You haven\'t ordered anything yet. Your sensory journey is waiting to be written.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: textColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}