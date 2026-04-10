part of 'cart_bloc.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class LoadCart extends CartEvent {
  final String userId;

  const LoadCart(this.userId);

  @override
  List<Object> get props => [userId];
}

class UpdateCart extends CartEvent {
  final List<CartItem> items;

  const UpdateCart(this.items);

  @override
  List<Object> get props => [items];
}

class CartErrorOccurred extends CartEvent {
  final String errorMessage;

  const CartErrorOccurred(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class AddProductToCart extends CartEvent {
  final String userId;
  final CartItem item;
  
  const AddProductToCart(this.userId, this.item);

  @override
  List<Object> get props => [userId, item];
}