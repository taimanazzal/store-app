import 'package:equatable/equatable.dart';

class Coupon extends Equatable {
  final String code;
  final double discountPercent;

  const Coupon({required this.code, required this.discountPercent});

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      code: json['code'] as String,
      discountPercent: (json['discount_percent'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [code, discountPercent];
}
