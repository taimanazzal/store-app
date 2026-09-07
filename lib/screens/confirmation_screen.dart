import 'package:flutter/material.dart';

/// Simple order-confirmation screen shown after checkout.
/// Uses pushAndRemoveUntil from the Cart screen so the user can't
/// navigate "back" into an already-cleared cart.
class ConfirmationScreen extends StatelessWidget {
  final double total;

  const ConfirmationScreen({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Confirmed')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text(
                'Thank you for your order!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Total paid: \$${total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Back to Shopping'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
