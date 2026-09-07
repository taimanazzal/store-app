import 'package:equatable/equatable.dart';
import '../../models/coupon.dart';

abstract class CouponState extends Equatable {
  const CouponState();

  @override
  List<Object?> get props => [];
}

class CouponInitial extends CouponState {
  const CouponInitial();
}

class CouponValidating extends CouponState {
  const CouponValidating();
}

class CouponApplied extends CouponState {
  final Coupon coupon;
  const CouponApplied(this.coupon);

  @override
  List<Object?> get props => [coupon];
}

class CouponError extends CouponState {
  final String message;
  const CouponError(this.message);

  @override
  List<Object?> get props => [message];
}
