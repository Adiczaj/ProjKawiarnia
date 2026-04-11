import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:order_repository/order_repository.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepo _orderRepo;

  OrderBloc(this._orderRepo) : super(const OrderInitial()) {
    
    on<SubmitOrder>((event, emit) async {
      emit(const OrderLoading());
      
      try {
        await _orderRepo.placeOrder(event.userId, event.order);
        
        emit(const OrderSuccess());
      } catch (e) {
        emit(const OrderFailure("Nie udało się złożyć zamówienia. Spróbuj ponownie."));
      }
    });
    
  }
}