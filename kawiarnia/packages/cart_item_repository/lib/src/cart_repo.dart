import 'models/models.dart';

abstract class CartRepo {
  
  Future<void> addToCart(String userId, CartItem item);
  
  Stream<List<CartItem>> getCart(String userId);
  
  Future<void> updateQuantity(String userId, String cartItemId, int newQuantity);
  Future<void> removeFromCart(String userId, String cartItemId);
}