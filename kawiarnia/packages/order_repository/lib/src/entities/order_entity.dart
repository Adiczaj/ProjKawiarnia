import 'order_items_entity.dart';

class OrderEntity {
  final String orderId;
  final String userId;
  final String deliveryAddress;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime deliveryDate;
  final String deliveryMethod;
  final String deliverySlot;
  final String status;
  final List<ItemsEntity> items;

  OrderEntity({
    required this.orderId,
    required this.userId,
    required this.deliveryAddress,
    required this.totalAmount,
    required this.createdAt,
    required this.deliveryDate,
    required this.deliveryMethod,
    required this.deliverySlot,
    required this.status,
    required this.items,
  });

  Map<String, Object?> toDocument() {
    return {
      'orderId': orderId,
      'userId': userId,
      'deliveryAddress': deliveryAddress,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'deliveryDate': deliveryDate.toIso8601String(),
      'deliveryMethod': deliveryMethod,
      'deliverySlot': deliverySlot,
      'status': status,
      'items': items.map((item) => item.toDocument()).toList(),
    };
  }

  static OrderEntity fromDocument(Map<String, dynamic> doc) {
    return OrderEntity(
      orderId: doc['orderId'] as String,
      userId: doc['userId'] as String,
      deliveryAddress: doc['deliveryAddress'] as String,
      totalAmount: (doc['totalAmount'] as num).toDouble(),
      createdAt: DateTime.parse(doc['createdAt'] as String),
      deliveryDate: DateTime.parse(doc['deliveryDate'] as String),
      deliveryMethod: doc['deliveryMethod'] as String,
      deliverySlot: doc['deliverySlot'] as String,
      status: doc['status'] as String,
      items: (doc['items'] as List<dynamic>)
          .map((item) => ItemsEntity.fromDocument(item as Map<String, dynamic>))
          .toList(),
    );
  }
}