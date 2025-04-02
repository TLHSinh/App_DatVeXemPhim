import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_datvexemphim/api/api_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email; // Nhận email từ màn hình trước đó

  const OtpVerificationScreen({Key? key, required this.email})
      : super(key: key);

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Hàm gửi OTP lên API
  Future<void> _verifyOtp() async {
    setState(() => _errorMessage = null);
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post("/auth/verifyOtp", {
        "email": widget.email,
        "otp": _otpController.text.trim(),
      });

      if (response != null && response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Xác thực OTP thành công!")),
        );

        // Điều hướng về Home và xóa toàn bộ các trang trước đó
        GoRouter.of(context).go('/login');
      } else {
        setState(
            () => _errorMessage = "⚠️ Mã OTP không hợp lệ hoặc đã hết hạn!");
      }
    } catch (e) {
      setState(() => _errorMessage = "⚠️ Lỗi server, thử lại sau!");
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Xác thực OTP"),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nhập mã OTP đã gửi đến email của bạn:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: "Mã OTP",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock, color: Colors.redAccent),
              ),
            ),
            const SizedBox(height: 10),
            _errorMessage != null
                ? Text(_errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14))
                : const SizedBox.shrink(),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Xác nhận OTP',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
