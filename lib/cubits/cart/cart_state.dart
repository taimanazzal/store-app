import 'package:equatable/equatable.dart';
import '../../models/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> items;

  /// Set right after an action that was capped/blocked by stock limits,
  /// so the UI can show a message (e.g. via SnackBar) if it wants to.
  final String? lastMessage;

  const CartState({this.items = const [], this.lastMessage});

  double get total => items.fold(0.0, (sum, item) => sum + item.subtotal);

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({
    List<CartItem>? items,
    String? lastMessage,
    bool clearMessage = false,
  }) {
    return CartState(
      items: items ?? this.items,
      lastMessage: clearMessage ? null : (lastMessage ?? this.lastMessage),
    );
  }

  @override
  List<Object?> get props => [items, lastMessage];
}
