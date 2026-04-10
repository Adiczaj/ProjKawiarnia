import '../entities/entities.dart';

class Product {
  final String productId;
  final String product;
  final String description;
  final String link;
  final double price;
  final bool milk;

  Product({
    required this.productId,
    required this.product,
    required this.description,
    required this.link,
    required this.price,
    required this.milk,
  });

  ProductEntity toEntity() {
    return ProductEntity(
      productId: productId,
      product: product,
      description: description,
      link: link,
      price: price,
      milk: milk,
    );
  }

  static Product fromEntity(ProductEntity entity) {
    return Product(
      productId: entity.productId,
      product: entity.product,
      description: entity.description,
      link: entity.link,
      price: entity.price,
      milk: entity.milk,
    );
  }
}