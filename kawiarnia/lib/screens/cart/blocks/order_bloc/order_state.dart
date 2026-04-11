part of 'order_bloc.dart';

abstract class OrderState extends Equatable {
  const OrderState();
  
  @override
  List<Object> get props => [];
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrderSuccess extends OrderState {
  const OrderSuccess();
}

class OrderFailure extends OrderState {
  final String errorMessage;

  const OrderFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}