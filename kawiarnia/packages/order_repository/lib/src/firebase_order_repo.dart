import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'order_repo.dart';
import 'models/models.dart';
import 'entities/entities.dart';

class FirebaseOrderRepo implements OrderRepo {
  final CollectionReference<Map<String, dynamic>> orderCollection =
      FirebaseFirestore.instance.collection('orders');
  final CollectionReference<Map<String, dynamic>> userCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  Future<void> placeOrder(String userId, Order order) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      final orderRef = orderCollection.doc();

      Map<String, dynamic> orderData = order.toEntity().toDocument();
      orderData['orderId'] = orderRef.id; 

      batch.set(orderRef, orderData);

      final cartRef = userCollection.doc(userId).collection('cart');
      final cartDocs = await cartRef.get();

      for (var doc in cartDocs.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

    } catch (e) {
      log('Błąd podczas składania zamówienia: $e');
      rethrow;
    }
  }

  @override
  Stream<List<Order>> getOrders(String userId) {
    log('Pobieranie zamówień dla userId: $userId');
    return orderCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      log('Otrzymano ${snapshot.docs.length} zamówień');
      final orders = snapshot.docs
          .map((doc) {
            try {
              return Order.fromEntity(OrderEntity.fromDocument(doc.data()));
            } catch (e) {
              log('Błąd konwersji zamówienia: $e');
              rethrow;
            }
          })
          .toList();
      
      // Sortujemy lokalnie po createdAt (malejąco)
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }
}