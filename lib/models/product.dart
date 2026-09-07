import 'package:equatable/equatable.dart';

/// Product model. Works with both the real Fake Store API response
/// (which has no `stock` field) and the local mock `products_data.json`
/// (which includes `stock`). If `stock` is missing we default to a
/// generous value so products from the live API are still purchasable.
class Product extends Equatable {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double rating;
  final int ratingCount;
  final int stock;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
    required this.ratingCount,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final ratingJson = json['rating'] as Map<String, dynamic>?;
    return Product(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      image: json['image'] as String? ?? '',
      rating: ratingJson != null ? (ratingJson['rate'] as num).toDouble() : 0.0,
      ratingCount: ratingJson != null
          ? (ratingJson['count'] as num).toInt()
          : 0,
      // Real Fake Store API has no stock field -> default to 999 (effectively unlimited)
      stock: json['stock'] != null ? (json['stock'] as num).toInt() : 999,
    );
  }

  bool get isInStock => stock > 0;

  @override
  List<Object?> get props => [
    id,
    title,
    price,
    description,
    category,
    image,
    rating,
    ratingCount,
    stock,
  ];
}
