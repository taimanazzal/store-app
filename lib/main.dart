import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/product_service.dart';
import 'cubits/products/products_cubit.dart';
import 'cubits/cart/cart_cubit.dart';
import 'cubits/favorites/favorites_cubit.dart';
import 'cubits/coupon/coupon_cubit.dart';
import 'screens/product_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final favoritesBox = await Hive.openBox(FavoritesCubit.boxName);
  runApp(StoreApp(favoritesBox: favoritesBox));
}

class StoreApp extends StatelessWidget {
  final Box favoritesBox;
  const StoreApp({super.key, required this.favoritesBox});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductsCubit>(
          create: (_) => ProductsCubit(ProductService()),
        ),
        BlocProvider<CartCubit>(create: (_) => CartCubit()),
        BlocProvider<FavoritesCubit>(
          create: (_) => FavoritesCubit(favoritesBox),
        ),
        BlocProvider<CouponCubit>(create: (_) => CouponCubit(ProductService())),
      ],
      child: MaterialApp(
        title: 'Store App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        home: const ProductListScreen(),
      ),
    );
  }
}
