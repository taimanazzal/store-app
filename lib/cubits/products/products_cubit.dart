import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/product_service.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ProductService _productService;

  ProductsCubit(this._productService) : super(const ProductsInitial());

  Future<void> loadProducts({bool forceMock = false}) async {
    emit(const ProductsLoading());
    try {
      final products = await _productService.fetchProducts(
        forceMock: forceMock,
      );
      emit(ProductsLoaded(allProducts: products, filteredProducts: products));
    } catch (e) {
      emit(ProductsError('Failed to load products: $e'));
    }
  }

  void search(String query) {
    final currentState = state;
    if (currentState is! ProductsLoaded) return;

    final trimmed = query.trim().toLowerCase();
    final filtered = trimmed.isEmpty
        ? currentState.allProducts
        : currentState.allProducts
              .where((p) => p.title.toLowerCase().contains(trimmed))
              .toList();

    emit(currentState.copyWith(filteredProducts: filtered, searchQuery: query));
  }
}
