import 'package:app_datvexemphim/presentation/widgets/final_view.dart';
import 'package:flutter/material.dart';

class PaymentFail extends StatefulWidget {
  const PaymentFail({super.key});

  @override
  State<PaymentFail> createState() => _PaymentFailState();
}

class _PaymentFailState extends State<PaymentFail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Payment successfully'),
        backgroundColor: Color(0xFF49606d),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Color(0xFF49606d),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            // mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 30,
              ),
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      // color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withOpacity(0.2), // Màu bóng đen nhẹ
                          spreadRadius: 1, // Mở rộng vùng bóng
                          blurRadius: 40, // Làm mờ bóng
                          offset: Offset(0, 8), // Dịch bóng xuống dưới
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/onboarding3.png',
                      scale: 5,
                      opacity: AlwaysStoppedAnimation(0.4),
                    ),
                  ),
                  Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          '404',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 45,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto'
                              //
                              ),
                        ),
                      ))
                ],
              ),
              // ClipRRect(
              //   borderRadius: BorderRadius.all(Radius.circular(100)),
              //   child: Container(
              //     padding: EdgeInsets.all(15),
              //     decoration: BoxDecoration(
              //       color: Colors.redAccent.withValues(alpha: .7),
              //       // Màu nền xanh lá
              //       shape: BoxShape.circle, // Đảm bảo hình tròn hoàn hảo
              //       boxShadow: [
              //         BoxShadow(
              //           color:
              //               Colors.black.withOpacity(0.3), // Màu bóng đen nhẹ
              //           spreadRadius: 5, // Mở rộng vùng bóng
              //           blurRadius: 15, // Làm mờ bóng
              //           offset: Offset(0, 8), // Dịch bóng xuống dưới
              //         ),
              //       ],
              //     ),
              //     child: Icon(
              //       Icons.check_rounded,
              //       size: 50,
              //       color: Colors.white,
              //     ),
              //   ),
              // ),
              // SizedBox(
              //   height: 10,
              // ),
              Text(
                'Oops!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  //
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Đã xảy ra lỗi!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      //
                    ),
                  ),
                  Text(
                    'Vui lòng thử lại sau...',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      //
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              SizedBox(
                width: 255,
                height: 45,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            FinalView(),
                      )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    'Về trang chủ',
                    style: TextStyle(
                        //
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
