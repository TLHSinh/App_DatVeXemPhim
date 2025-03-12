import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "assets/images/splash_background.jpg"), // Dùng background giống SplashScreen
            fit: BoxFit.cover,
          ),
        ),
        child: AnimatedOpacity(
          duration: Duration(seconds: 1),
          opacity: _opacity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3, // Đẩy logo lên trên nhưng vẫn cân đối
                child: Center(
                  child: Image.asset(
                    'assets/images/logofull2.png',
                    height: 200, // Tăng kích thước logo
                  ),
                ),
              ),
              Expanded(
                flex: 2, // Hiệu ứng loading ở giữa
                child: SpinKitFadingCircle(
                  color: Color(0xFF545454),
                  size: 70.0, // Tăng kích thước loading spinner
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
                        color: Color(0xFF545454),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Vui lòng chờ trong giây lát",
                      style: TextStyle(
                        color: Color(0xFF545454),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
