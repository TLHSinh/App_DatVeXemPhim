import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Hiệu ứng fade-in khi vào màn hình
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Chờ 3 giây rồi chuyển sang OnboardingScreen
    Timer(Duration(seconds: 3), () {
      context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: AnimatedOpacity(
        duration: Duration(seconds: 1),
        opacity: _opacity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3, // Đẩy logo lên trên nhưng vẫn cân đối
              child: Center(
                child: Image.asset(
                  'assets/images/logofull.png',
                  height: 160, // Điều chỉnh kích thước hợp lý
                ),
              ),
            ),
            Expanded(
              flex: 2, // Hiệu ứng loading ở giữa
              child: SpinKitFadingCircle(
                color: Colors.red,
                size: 50.0,
              ),
            ),
            Expanded(
              flex: 2, // Đoạn chữ phía dưới
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "ĐANG TẢI DỮ LIỆU...",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Vui lòng chờ trong giây lát",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
