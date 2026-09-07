import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/cart/cart_cubit.dart';
import '../cubits/cart/cart_state.dart';
import '../cubits/coupon/coupon_cubit.dart';
import '../cubits/coupon/coupon_state.dart';
import 'confirmation_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: BlocBuilder<CartCubit, CartState>(
        bloc: context.read<CartCubit>(),
        builder: (context, cartState) {
          if (cartState.items.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: cartState.items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = cartState.items[index];
                    return ListTile(
                      leading: SizedBox(
                        width: 48,
                        height: 48,
                        child: Image.network(
                          item.product.image,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                      title: Text(
                        item.product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              size: 20,
                            ),
                            onPressed: () =>
                                context.read<CartCubit>().updateQuantity(
                                  item.product.id,
                                  item.quantity - 1,
                                ),
                          ),
                          Text('${item.quantity}'),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 20,
                            ),
                            onPressed: item.quantity < item.product.stock
                                ? () =>
                                      context.read<CartCubit>().updateQuantity(
                                        item.product.id,
                                        item.quantity + 1,
                                      )
                                : null,
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${item.subtotal.toStringAsFixed(2)}'),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () => context
                                .read<CartCubit>()
                                .removeItem(item.product.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              _buildCouponAndTotal(context, cartState),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCouponAndTotal(BuildContext context, CartState cartState) {
    return BlocBuilder<CouponCubit, CouponState>(
      bloc: context.read<CouponCubit>(),
      builder: (context, couponState) {
        final subtotal = cartState.total;

        double discountPercent = 0;
        if (couponState is CouponApplied) {
          discountPercent = couponState.coupon.discountPercent;
        }
        final discountAmount = subtotal * discountPercent / 100;
        final finalTotal = subtotal - discountAmount;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Coupon input row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponController,
                      enabled: couponState is! CouponApplied,
                      decoration: const InputDecoration(
                        hintText: 'Coupon code',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (couponState is CouponApplied)
                    OutlinedButton(
                      onPressed: () {
                        context.read<CouponCubit>().removeCoupon();
                        _couponController.clear();
                      },
                      child: const Text('Remove'),
                    )
                  else
                    ElevatedButton(
                      onPressed: couponState is CouponValidating
                          ? null
                          : () => context.read<CouponCubit>().applyCoupon(
                              _couponController.text,
                            ),
                      child: couponState is CouponValidating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Apply'),
                    ),
                ],
              ),
              if (couponState is CouponError) ...[
                const SizedBox(height: 4),
                Text(
                  couponState.message,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              if (couponState is CouponApplied) ...[
                const SizedBox(height: 4),
                Text(
                  'Coupon "${couponState.coupon.code}" applied (-${couponState.coupon.discountPercent.toStringAsFixed(0)}%)',
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
              const SizedBox(height: 12),

              // Totals
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal'),
                  Text('\$${subtotal.toStringAsFixed(2)}'),
                ],
              ),
              if (discountAmount > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Discount',
                      style: TextStyle(color: Colors.green),
                    ),
                    Text(
                      '-\$${discountAmount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '\$${finalTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  final paidTotal = finalTotal;
                  context.read<CartCubit>().clearCart();
                  context.read<CouponCubit>().removeCoupon();
                  _couponController.clear();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => ConfirmationScreen(total: paidTotal),
                    ),
                  );
                },
                child: const Text('Checkout'),
              ),
            ],
          ),
        );
      },
    );
  }
}
