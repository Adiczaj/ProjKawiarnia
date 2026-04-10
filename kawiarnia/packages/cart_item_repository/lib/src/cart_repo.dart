import 'models/models.dart';

abstract class CartRepo {
  
  Future<void> addToCart(String userId, CartItem item);
  
  Stream<List<CartItem>> getCart(String userId);
}