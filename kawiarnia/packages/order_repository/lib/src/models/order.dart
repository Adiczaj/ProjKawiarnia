import '../entities/entities.dart';
import 'models.dart';

class Order {
  final String orderId;
  final String userId;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime deliveryDate;
  final String deliveryMethod;
  final String deliverySlot;
  final String status;
  final List<Items> items;

  Order({
    required this.orderId,
    required this.userId,
    required this.totalAmount,
    required this.createdAt,
    required this.deliveryDate,
    required this.deliveryMethod,
    required this.deliverySlot,
    required this.status,
    required this.items,
  });

  OrderEntity toEntity() {
    return OrderEntity(
      orderId: orderId,
      userId: userId,
      totalAmount: totalAmount,
      createdAt: createdAt,
      deliveryDate: deliveryDate,
      deliveryMethod: deliveryMethod,
      deliverySlot: deliverySlot,
      status: status,
      items: items.map((item) => item.toEntity()).toList(),
    );
  }

  static Order fromEntity(OrderEntity entity) {
    return Order(
      orderId: entity.orderId,
      userId: entity.userId,
      totalAmount: entity.totalAmount,
      createdAt: entity.createdAt,
      deliveryDate: entity.deliveryDate,
      deliveryMethod: entity.deliveryMethod,
      deliverySlot: entity.deliverySlot,
      status: entity.status,
      items: entity.items.map((itemEntity) => Items.fromEntity(itemEntity)).toList(),
    );
  }
}