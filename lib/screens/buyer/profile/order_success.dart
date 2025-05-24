import 'package:flutter/material.dart';

class OrderSuccessPage extends StatelessWidget {
  final int orderId;

  const OrderSuccessPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order Confirmed")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text("Your order has been placed!", style: TextStyle(fontSize: 18)),
            Text("Order ID: $orderId", style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
              },
              child: const Text("Back to Home"),
            )
          ],
        ),
      ),
    );
  }
}
