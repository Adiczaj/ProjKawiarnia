class ProductEntity {
  final String productId;
  final String product;
  final String description;
  final String link;
  final double price;

  ProductEntity({
    required this.productId,
    required this.product,
    required this.description,
    required this.link,
    required this.price,
  });

  Map<String, Object?> toDocument() {
    return {
      'productId': productId,
      'product': product,
      'description': description,
      'link': link,
      'price': price,
    };
  }

  static ProductEntity fromDocument(Map<String, dynamic> doc) {
    return ProductEntity(
      productId: doc['productId'] as String,
      product: doc['product'] as String,
      description: doc['description'] as String,
      link: doc['link'] as String,
      price: (doc['price'] as num).toDouble(),
    );
  }
}