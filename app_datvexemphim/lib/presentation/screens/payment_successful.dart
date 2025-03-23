import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentSuccessful extends StatefulWidget {
  const PaymentSuccessful({
    super.key,
  });

  @override
  State<PaymentSuccessful> createState() => _PaymentSuccessfulState();
}

class _PaymentSuccessfulState extends State<PaymentSuccessful> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment successfully'),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: ElevatedButton(
              onPressed: () {
                // Navigator.pushReplacement(
                //     context,
                //     PageRouteBuilder(
                //       pageBuilder: (context, animation, secondaryAnimation) =>
                //           FinalView(),
                //     ));
                if (mounted) {
                  GoRouter.of(context).push('/home');
                }
              },
              child: Text('Move to Home')),
        ),
      ),
    );
  }
}
