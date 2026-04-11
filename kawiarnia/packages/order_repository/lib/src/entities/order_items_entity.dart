class ItemsEntity{
  final String productId;
  final String product;
  final String link;
  final double price;
  final int quantity;
  final String size;
  final String sugar;
  final String milk;

  ItemsEntity({
    required this.productId,
    required this.product,
    required this.link,
    required this.price,
    required this.quantity,
    required this.size,
    required this.sugar,
    required this.milk,
  });

  Map<String, Object?> toDocument() {
    return {
      'productId': productId,
      'product': product,
      'link': link,
      'price': price,
      'quantity': quantity,
      'size': size,
      'sugar': sugar,
      'milk': milk,
    };
  }

  static ItemsEntity fromDocument(Map<String, dynamic> doc) {
    return ItemsEntity(
      productId: doc['productId'] as String,
      product: doc['product'] as String,
      link: doc['link'] as String,
      price: (doc['price'] as num).toDouble(),
      quantity: doc['quantity'] as int,
      size: doc['size'] as String,
      sugar: doc['sugar'] as String,
      milk: doc['milk'] as String,
    );
  }

}