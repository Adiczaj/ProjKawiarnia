import 'models/models.dart';

abstract class OrderRepo {

  Future<void> placeOrder(String userId, Order order);
  
  Stream<List<Order>> getOrders(String userId);
}