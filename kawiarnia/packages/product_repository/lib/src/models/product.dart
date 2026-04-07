import '../entities/entities.dart';

class Product {
  final String productId;
  final String product;
  final String description;
  final String link;
  final double price;

  Product({
    required this.productId,
    required this.product,
    required this.description,
    required this.link,
    required this.price,
  });

  ProductEntity toEntity() {
    return ProductEntity(
      productId: productId,
      product: product,
      description: description,
      link: link,
      price: price,
    );
  }

  static Product fromEntity(ProductEntity entity) {
    return Product(
      productId: entity.productId,
      product: entity.product,
      description: entity.description,
      link: entity.link,
      price: entity.price,
    );
  }
}