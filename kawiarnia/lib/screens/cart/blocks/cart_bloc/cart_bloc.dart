import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cart_item_repository/cart_repository.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepo _cartRepo; 
  StreamSubscription? _cartSubscription;

  CartBloc(this._cartRepo) : super(CartInitial()) {
    
    on<LoadCart>((event, emit) {
      emit(CartLoading());
      
      _cartSubscription?.cancel();
      
      _cartSubscription = _cartRepo.getCart(event.userId).listen(
        (items) {
          add(UpdateCart(items));
        },
        onError: (error) {
          add(CartErrorOccurred(error.toString()));
        },
      );
    });

    on<UpdateCart>((event, emit) {
      double total = event.items.fold(
        0.0, 
        (sum, item) => sum + (item.price * item.quantity)
      );
      
      emit(CartLoaded(event.items, total));
    });

    on<CartErrorOccurred>((event, emit) {
      emit(CartFailure(event.errorMessage));
    });

    on<AddProductToCart>((event, emit) async {
      try {
        await _cartRepo.addToCart(event.userId, event.item);
        add(LoadCart(event.userId));
      } catch (e) {
        emit(const CartFailure("Nie udało się dodać produktu do koszyka."));
      }
    });

    on<UpdateItemQuantity>((event, emit) async {
      try {
        await _cartRepo.updateQuantity(event.userId, event.cartItemId, event.newQuantity);
        //add(LoadCart(event.userId));
      } catch (e) {
        emit(const CartFailure("Nie udało się zaktualizować ilości."));
      }
    });

    on<RemoveItemFromCart>((event, emit) async {
      try {
        await _cartRepo.removeFromCart(event.userId, event.cartItemId);
        //add(LoadCart(event.userId));
      } catch (e) {
        emit(const CartFailure("Nie udało się usunąć produktu."));
      }
    });
  }

  @override
  Future<void> close() {
    _cartSubscription?.cancel();
    return super.close();
  }
}