import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/cart_item.dart';
import '../../models/product.dart';
import 'cart_state.dart';

/// Manages the shopping cart as pure local state (the Fake Store API's
/// write operations are fake and don't persist, so the cart never talks
/// to the network).
///
/// All stock-limit checks live here (not in the UI) so quantity can never
/// exceed a product's available stock no matter which screen calls in.
class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  /// Adds [quantity] of [product] to the cart. If the product is already
  /// in the cart, quantities are combined. The final quantity is always
  /// clamped to the product's stock.
  void addItem(Product product, int quantity) {
    if (!product.isInStock || quantity <= 0) {
      emit(state.copyWith(lastMessage: '${product.title} is out of stock'));
      return;
    }

    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((item) => item.product.id == product.id);

    String? message;

    if (index == -1) {
      final clamped = _clampToStock(quantity, product.stock);
      if (clamped < quantity) {
        message = 'Only ${product.stock} of ${product.title} in stock';
      }
      items.add(CartItem(product: product, quantity: clamped));
    } else {
      final existing = items[index];
      final desired = existing.quantity + quantity;
      final clamped = _clampToStock(desired, product.stock);
      if (clamped < desired) {
        message = 'Only ${product.stock} of ${product.title} in stock';
      }
      items[index] = existing.copyWith(quantity: clamped);
    }

    emit(
      state.copyWith(
        items: items,
        lastMessage: message,
        clearMessage: message == null,
      ),
    );
  }

  /// Sets the quantity of an existing cart item directly, clamped to
  /// stock (min 1). Used by the +/- controls on the Cart screen.
  void updateQuantity(int productId, int quantity) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((item) => item.product.id == productId);
    if (index == -1) return;

    final product = items[index].product;
    var clamped = quantity;
    if (clamped < 1) clamped = 1;
    if (clamped > product.stock) clamped = product.stock;
    items[index] = items[index].copyWith(quantity: clamped);

    emit(state.copyWith(items: items, clearMessage: true));
  }

  void removeItem(int productId) {
    final items = state.items
        .where((item) => item.product.id != productId)
        .toList();
    emit(state.copyWith(items: items, clearMessage: true));
  }

  void clearCart() {
    emit(const CartState());
  }

  /// Whether [quantity] more of [product] can still be added given what's
  /// already in the cart. Used by the details screen to disable "+".
  bool canAddMore(Product product, {int currentCartQuantity = 0}) {
    return currentCartQuantity < product.stock;
  }

  int quantityInCart(int productId) {
    final match = state.items.where((item) => item.product.id == productId);
    if (match.isEmpty) return 0;
    return match.first.quantity;
  }

  int _clampToStock(int quantity, int stock) {
    if (stock <= 0) return 0;
    if (quantity > stock) return stock;
    if (quantity < 0) return 0;
    return quantity;
  }
}
