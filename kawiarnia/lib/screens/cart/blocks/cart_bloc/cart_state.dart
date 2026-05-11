part of 'cart_bloc.dart';

sealed class CartState extends Equatable {
  const CartState();
  
  @override
  List<Object> get props => [];
}

final class CartInitial extends CartState {}

final class CartLoading extends CartState {}

final class CartLoaded extends CartState {
  final List<CartItem> items;
  final double totalPrice;

  const CartLoaded(this.items, this.totalPrice);

  @override
  List<Object> get props => [items, totalPrice];
}

final class CartFailure extends CartState {
  final String errorMessage;

  const CartFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}