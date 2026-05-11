import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_repo.dart';
import 'models/models.dart';
import 'entities/entities.dart';

class FirebaseCartRepo implements CartRepo {
  final CollectionReference userCollection = 
      FirebaseFirestore.instance.collection('users');

  @override
  Future<void> addToCart(String userId, CartItem item) async {
    try {
      final cartRef = userCollection.doc(userId).collection('cart');

      final querySnapshot = await cartRef
          .where('productId', isEqualTo: item.productId)
          .where('size', isEqualTo: item.size)
          .where('sugar', isEqualTo: item.sugar)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final existingDoc = querySnapshot.docs.first;
        final existingQuantity = existingDoc['quantity'] as int;
        
        await existingDoc.reference.update({
          'quantity': existingQuantity + item.quantity,
        });
      } else {
        final newDocRef = cartRef.doc(); 
        Map<String, dynamic> docData = item.toEntity().toDocument();
        docData['cartId'] = newDocRef.id; 
        await newDocRef.set(docData);
      }
    } catch (e) {
      log('Błąd podczas dodawania do koszyka: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateQuantity(String userId, String cartItemId, int newQuantity) async {
    try {
      await userCollection
          .doc(userId)
          .collection('cart')
          .doc(cartItemId)
          .update({'quantity': newQuantity});
    } catch (e) {
      log("Błąd aktualizacji ilości: $e");
      rethrow;
    }
  }

  @override
  Future<void> removeFromCart(String userId, String cartItemId) async {
    try {
      await userCollection
          .doc(userId)
          .collection('cart')
          .doc(cartItemId)
          .delete();
    } catch (e) {
      log("Błąd usuwania z koszyka: $e");
      rethrow;
    }
  }

  @override
  Stream<List<CartItem>> getCart(String userId) {
    return userCollection
        .doc(userId)
        .collection('cart')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CartItem.fromEntity(CartItemEntity.fromDocument(doc.data()..addAll({'id': doc.id}))))
          .toList();
    });
  }
}