import '../entities/cart_item_entity.dart';

class CartItem {
  final String cartId;
  final String productId;
  final String product;
  final String link;
  final double price;
  final int quantity;
  final String size;
  final String sugar;
  final String milk;

  CartItem({
    required this.cartId,
    required this.productId,
    required this.product,
    required this.link,
    required this.price,
    required this.quantity,
    required this.size,
    required this.sugar,
    required this.milk,
  });

  CartItemEntity toEntity() {
    return CartItemEntity(
      cartId: cartId,
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

  static CartItem fromEntity(CartItemEntity entity) {
    return CartItem(
      cartId: entity.cartId,
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