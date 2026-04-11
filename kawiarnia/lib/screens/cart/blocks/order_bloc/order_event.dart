part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}

class SubmitOrder extends OrderEvent {
  final String userId;
  final Order order;

  const SubmitOrder(this.userId, this.order);

  @override
  List<Object> get props => [userId, order];
}