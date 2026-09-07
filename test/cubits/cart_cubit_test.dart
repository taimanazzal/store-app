import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/cubits/cart/cart_cubit.dart';
import 'package:store_app/cubits/cart/cart_state.dart';
import 'package:store_app/models/product.dart';

void main() {
  const inStockProduct = Product(
    id: 1,
    title: 'Watch',
    price: 100,
    description: 'desc',
    category: 'cat',
    image: 'img',
    rating: 4.5,
    ratingCount: 20,
    stock: 3,
  );
  const outOfStockProduct = Product(
    id: 2,
    title: 'Shirt',
    price: 50,
    description: 'desc',
    category: 'cat',
    image: 'img',
    rating: 4.0,
    ratingCount: 10,
    stock: 0,
  );

  group('CartCubit', () {
    test('initial state is an empty cart', () {
      final cubit = CartCubit();
      expect(cubit.state.items, isEmpty);
      expect(cubit.state.total, 0);
      expect(cubit.state.itemCount, 0);
    });

    blocTest<CartCubit, CartState>(
      'addItem adds a new product with the requested quantity',
      build: () => CartCubit(),
      act: (cubit) => cubit.addItem(inStockProduct, 2),
      verify: (cubit) {
        expect(cubit.state.items.length, 1);
        expect(cubit.state.items.first.quantity, 2);
        expect(cubit.state.total, 200);
      },
    );

    blocTest<CartCubit, CartState>(
      'addItem clamps quantity to available stock (stock = 3, requested = 10)',
      build: () => CartCubit(),
      act: (cubit) => cubit.addItem(inStockProduct, 10),
      verify: (cubit) {
        expect(cubit.state.items.first.quantity, 3);
        expect(cubit.state.lastMessage, isNotNull);
      },
    );

    blocTest<CartCubit, CartState>(
      'addItem combines quantities on repeat add, still clamped to stock',
      build: () => CartCubit(),
      act: (cubit) {
        cubit.addItem(inStockProduct, 2);
        cubit.addItem(inStockProduct, 2); // desired = 4, stock = 3
      },
      verify: (cubit) {
        expect(cubit.state.items.length, 1);
        expect(cubit.state.items.first.quantity, 3);
      },
    );

    blocTest<CartCubit, CartState>(
      'addItem does nothing for an out-of-stock product',
      build: () => CartCubit(),
      act: (cubit) => cubit.addItem(outOfStockProduct, 1),
      verify: (cubit) {
        expect(cubit.state.items, isEmpty);
        expect(cubit.state.lastMessage, contains('out of stock'));
      },
    );

    blocTest<CartCubit, CartState>(
      'updateQuantity clamps to stock and to a minimum of 1',
      build: () => CartCubit(),
      act: (cubit) {
        cubit.addItem(inStockProduct, 1);
        cubit.updateQuantity(inStockProduct.id, 10); // clamp to 3
      },
      verify: (cubit) => expect(cubit.state.items.first.quantity, 3),
    );

    blocTest<CartCubit, CartState>(
      'removeItem removes the product from the cart',
      build: () => CartCubit(),
      act: (cubit) {
        cubit.addItem(inStockProduct, 1);
        cubit.removeItem(inStockProduct.id);
      },
      verify: (cubit) => expect(cubit.state.items, isEmpty),
    );

    blocTest<CartCubit, CartState>(
      'clearCart empties the cart and resets the total',
      build: () => CartCubit(),
      act: (cubit) {
        cubit.addItem(inStockProduct, 2);
        cubit.clearCart();
      },
      verify: (cubit) {
        expect(cubit.state.items, isEmpty);
        expect(cubit.state.total, 0);
      },
    );
  });
}
