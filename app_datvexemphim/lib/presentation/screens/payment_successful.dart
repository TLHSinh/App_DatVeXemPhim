import 'package:app_datvexemphim/presentation/widgets/final_view.dart';
import 'package:flutter/material.dart';

class PaymentSuccessful extends StatefulWidget {
  final Map<String, String> queryParams;
  const PaymentSuccessful({super.key, required this.queryParams});

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
                Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          FinalView(),
                    ));
              },
              child: Text('Move to Home')),
        ),
      ),
    );
  }
}
