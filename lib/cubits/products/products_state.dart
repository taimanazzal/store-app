import 'package:equatable/equatable.dart';
import '../../models/product.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

class ProductsLoaded extends ProductsState {
  final List<Product> allProducts;
  final List<Product> filteredProducts;
  final String searchQuery;

  const ProductsLoaded({
    required this.allProducts,
    required this.filteredProducts,
    this.searchQuery = '',
  });

  ProductsLoaded copyWith({
    List<Product>? allProducts,
    List<Product>? filteredProducts,
    String? searchQuery,
  }) {
    return ProductsLoaded(
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [allProducts, filteredProducts, searchQuery];
}

class ProductsError extends ProductsState {
  final String message;

  const ProductsError(this.message);

  @override
  List<Object?> get props => [message];
}
