import 'package:app_datvexemphim/presentation/widgets/final_view.dart';
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
        // title: const Text('Payment successfully'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            // mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 100,
              ),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.redAccent
                        .withValues(alpha: .7), // Màu nền xanh lá
                    shape: BoxShape.circle, // Đảm bảo hình tròn hoàn hảo
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(0.3), // Màu bóng đen nhẹ
                        spreadRadius: 5, // Mở rộng vùng bóng
                        blurRadius: 15, // Làm mờ bóng
                        offset: Offset(0, 8), // Dịch bóng xuống dưới
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Thanh toán thành công',
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.bold
                    //
                    ),
              ),
              SizedBox(
                height: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '*Vui lòng chọn tab VÉ sau khi quay về',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 15,
                      fontFamily: 'Arial',
                      fontWeight: FontWeight.normal,
                      //
                    ),
                  ),
                  Text(
                    'trang chủ để xem vé của mình!',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 15,
                      fontFamily: 'Arial',
                      fontWeight: FontWeight.normal,
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
                    backgroundColor: Colors.redAccent,
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
