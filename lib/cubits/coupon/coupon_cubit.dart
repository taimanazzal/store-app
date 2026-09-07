import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/product_service.dart';
import 'coupon_state.dart';

/// Independent cubit that only knows about coupon codes — it has no
/// knowledge of the cart or its total. The Cart screen combines this
/// cubit's state with CartCubit's state to compute the discounted total,
/// without merging the two cubits together.
class CouponCubit extends Cubit<CouponState> {
  final ProductService _productService;

  CouponCubit(this._productService) : super(const CouponInitial());

  Future<void> applyCoupon(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      emit(const CouponError('Please enter a coupon code'));
      return;
    }

    emit(const CouponValidating());
    try {
      final coupons = await _productService.fetchCoupons();
      final match = coupons.where(
        (c) => c.code.toUpperCase() == trimmed.toUpperCase(),
      );

      if (match.isEmpty) {
        emit(const CouponError('Invalid coupon code'));
      } else {
        emit(CouponApplied(match.first));
      }
    } catch (e) {
      emit(CouponError('Failed to validate coupon: $e'));
    }
  }

  void removeCoupon() {
    emit(const CouponInitial());
  }
}
