import 'models/models.dart';

abstract class ProductRepo {
  Future<List<Product>> getProducts();
}