import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_datvexemphim/api/api_service.dart';
import '../../data/services/storage_service.dart'; // File quản lý lưu trữ

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() => _errorMessage = null);

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = "Vui lòng nhập đầy đủ thông tin!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post("/auth/loginUser", {
        "email": _emailController.text.trim(),
        "matKhau": _passwordController.text.trim(),
      });

      if (response == null) {
        setState(() => _errorMessage = "⚠️ Lỗi kết nối đến server!");
        return;
      }

      if (response.statusCode == 200) {
        print("✅ Đăng nhập thành công!");

        String token = response.data['token'];
        String userId = response.data['data']['_id'];

        // Lưu vào SharedPreferences
        await StorageService.saveUserData(token, userId);

        // Chuyển hướng đến màn hình chính
        GoRouter.of(context).go('/home');
        if (context.mounted) {
          context.pop(true); // Trả về true sau khi đăng nhập thành công
        }
      } else {
        setState(() => _errorMessage = "❌ Sai tài khoản hoặc mật khẩu!");
      }
    } catch (e) {
      setState(() => _errorMessage = "⚠️ Lỗi đăng nhập, thử lại!");
    }

    setState(() => _isLoading = false);
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: hint,
        labelStyle: const TextStyle(color: Color(0xFF545454)),
        prefixIcon: Icon(icon, color: Color(0xFFee0033)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Color(0xFFee0033),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFC20077)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => GoRouter.of(context).go('/home'),
        ),
        //title: Text("Đăng nhập", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child:
                        Image.asset('assets/images/logofull2.png', width: 500),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Đăng nhập',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(_emailController, "Email", Icons.email),
                  const SizedBox(height: 15),
                  _buildTextField(_passwordController, "Mật khẩu", Icons.lock,
                      isPassword: true),
                  const SizedBox(height: 10),
                  _errorMessage != null
                      ? Text(_errorMessage!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 14))
                      : const SizedBox.shrink(),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        color: const Color.fromARGB(255, 255, 243, 243),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _login,
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
                        'Đăng nhập',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => GoRouter.of(context).go('/register'),
              child: const Text(
                "Chưa có tài khoản? Đăng ký ngay",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
