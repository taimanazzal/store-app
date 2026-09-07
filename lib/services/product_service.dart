import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/coupon.dart';

/// Handles all data fetching for products & coupons.
///
/// Products: tries the real Fake Store API first. If that fails
/// (no internet, timeout, etc.) it silently falls back to the local
/// `assets/products_data.json` mock file so the app keeps working offline.
///
/// Coupons: the real API has no coupons endpoint, so coupons always
/// come from the local mock file.
class ProductService {
  static const String baseUrl = 'https://fakestoreapi.com';
  static const String mockAssetPath = 'assets/products_data.json';

  final http.Client _client;

  ProductService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Product>> fetchProducts({bool forceMock = false}) async {
    if (!forceMock) {
      try {
        final response = await _client
            .get(Uri.parse('$baseUrl/products'))
            .timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
          return data
              .map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {
        // fall through to mock data
      }
    }
    return _loadMockProducts();
  }

  Future<List<Product>> _loadMockProducts() async {
    final jsonString = await rootBundle.loadString(mockAssetPath);
    final Map<String, dynamic> data =
        jsonDecode(jsonString) as Map<String, dynamic>;
    final List<dynamic> productsJson = data['products'] as List<dynamic>;
    return productsJson
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Coupon>> fetchCoupons() async {
    final jsonString = await rootBundle.loadString(mockAssetPath);
    final Map<String, dynamic> data =
        jsonDecode(jsonString) as Map<String, dynamic>;
    final List<dynamic> couponsJson = data['coupons'] as List<dynamic>? ?? [];
    return couponsJson
        .map((e) => Coupon.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
