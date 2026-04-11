import '../entities/order_items_entity.dart';

class Items {
  final String productId;
  final String product;
  final String link;
  final double price;
  final int quantity;
  final String size;
  final String sugar;
  final String milk;

  Items({
    required this.productId,
    required this.product,
    required this.link,
    required this.price,
    required this.quantity,
    required this.size,
    required this.sugar,
    required this.milk,
  });

  ItemsEntity toEntity() {
    return ItemsEntity(
      productId: productId,
      product: product,
      link: link,
      price: price,
      quantity: quantity,
      size: size,
      sugar: sugar,
      milk: milk,
    );
  }

  static Items fromEntity(ItemsEntity entity) {
    return Items(
      productId: entity.productId,
      product: entity.product,
      link: entity.link,
      price: entity.price,
      quantity: entity.quantity,
      size: entity.size,
      sugar: entity.sugar,
      milk: entity.milk,
    );
  }
}