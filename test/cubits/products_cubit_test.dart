import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:store_app/cubits/products/products_cubit.dart';
import 'package:store_app/cubits/products/products_state.dart';
import 'package:store_app/models/product.dart';
import 'package:store_app/services/product_service.dart';

class MockProductService extends Mock implements ProductService {}

void main() {
  late MockProductService productService;

  const product1 = Product(
    id: 1,
    title: 'Apple',
    price: 10,
    description: 'desc',
    category: 'cat',
    image: 'img',
    rating: 4.0,
    ratingCount: 10,
    stock: 5,
  );
  const product2 = Product(
    id: 2,
    title: 'Banana',
    price: 5,
    description: 'desc',
    category: 'cat',
    image: 'img',
    rating: 4.0,
    ratingCount: 10,
    stock: 0,
  );

  setUp(() {
    productService = MockProductService();
  });

  group('ProductsCubit', () {
    test('initial state is ProductsInitial', () {
      final cubit = ProductsCubit(productService);
      expect(cubit.state, const ProductsInitial());
    });

    blocTest<ProductsCubit, ProductsState>(
      'emits [Loading, Loaded] when fetchProducts succeeds',
      build: () {
        when(
          () =>
              productService.fetchProducts(forceMock: any(named: 'forceMock')),
        ).thenAnswer((_) async => [product1, product2]);
        return ProductsCubit(productService);
      },
      act: (cubit) => cubit.loadProducts(),
      expect: () => [
        const ProductsLoading(),
        const ProductsLoaded(
          allProducts: [product1, product2],
          filteredProducts: [product1, product2],
        ),
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'emits [Loading, Error] when fetchProducts throws',
      build: () {
        when(
          () =>
              productService.fetchProducts(forceMock: any(named: 'forceMock')),
        ).thenThrow(Exception('network error'));
        return ProductsCubit(productService);
      },
      act: (cubit) => cubit.loadProducts(),
      expect: () => [const ProductsLoading(), isA<ProductsError>()],
    );

    blocTest<ProductsCubit, ProductsState>(
      'search filters products by title (case-insensitive), ignoring the API',
      build: () {
        when(
          () =>
              productService.fetchProducts(forceMock: any(named: 'forceMock')),
        ).thenAnswer((_) async => [product1, product2]);
        return ProductsCubit(productService);
      },
      act: (cubit) async {
        await cubit.loadProducts();
        cubit.search('app'); // should match "Apple" only
      },
      expect: () => [
        const ProductsLoading(),
        const ProductsLoaded(
          allProducts: [product1, product2],
          filteredProducts: [product1, product2],
        ),
        isA<ProductsLoaded>().having(
          (s) => s.filteredProducts,
          'filteredProducts',
          [product1],
        ),
      ],
      verify: (_) {
        // search() never re-calls the service
        verify(
          () =>
              productService.fetchProducts(forceMock: any(named: 'forceMock')),
        ).called(1);
      },
    );

    blocTest<ProductsCubit, ProductsState>(
      'search with empty query returns all products',
      build: () {
        when(
          () =>
              productService.fetchProducts(forceMock: any(named: 'forceMock')),
        ).thenAnswer((_) async => [product1, product2]);
        return ProductsCubit(productService);
      },
      act: (cubit) async {
        await cubit.loadProducts();
        cubit.search('xyz');
        cubit.search('');
      },
      skip: 2, // skip Loading + first Loaded (already covered above)
      expect: () => [
        isA<ProductsLoaded>().having(
          (s) => s.filteredProducts.length,
          'filtered count',
          0,
        ),
        isA<ProductsLoaded>().having(
          (s) => s.filteredProducts.length,
          'filtered count',
          2,
        ),
      ],
    );
  });
}
