import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentSuccessful extends StatefulWidget {
  const PaymentSuccessful({super.key});

  @override
  State<PaymentSuccessful> createState() => _PaymentSuccessfulState();
}

class _PaymentSuccessfulState extends State<PaymentSuccessful> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment successfully'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              context.go('/home'); // Điều hướng về home và mở tab thứ 2
            },
            child: const Text('Move to your Ticket'),
          ),
        ),
      ),
    );
  }
}
