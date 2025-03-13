import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_datvexemphim/api/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() => _errorMessage = null);

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = "Vui lòng nhập đầy đủ thông tin!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post("/auth/login", {
        "email": _emailController.text.trim(),
        "matKhau": _passwordController.text.trim(),
      });

      if (response == null) {
        setState(() => _errorMessage = "⚠️ Lỗi kết nối đến server!");
        return;
      }

      if (response.statusCode == 200) {
        print("✅ Đăng nhập thành công!");
        GoRouter.of(context).go('/home');
      } else {
        setState(() => _errorMessage = "❌ Sai tài khoản hoặc mật khẩu!");
      }
    } catch (e) {
      print("❌ Lỗi đăng nhập: $e");
      setState(() => _errorMessage = "⚠️ Lỗi đăng nhập, thử lại!");
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset('assets/images/logofull.png', width: 600),
              ),
              SizedBox(height: 40),
              const Text(
                'Đăng nhập',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 20),
              _buildTextField(_emailController, "Email",
                  focusNode: _emailFocus, nextFocus: _passwordFocus),
              const SizedBox(height: 15),
              _buildTextField(_passwordController, "Mật khẩu",
                  isPassword: true,
                  focusNode: _passwordFocus,
                  submitAction: _login),
              const SizedBox(height: 10),
              _errorMessage != null
                  ? Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14))
                  : const SizedBox.shrink(),
              const SizedBox(height: 25),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'Đăng nhập',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => GoRouter.of(context).go('/register'),
                  child: const Text(
                    "Chưa có tài khoản? Đăng ký ngay",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool isPassword = false,
      FocusNode? focusNode,
      FocusNode? nextFocus,
      Function? submitAction}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      focusNode: focusNode,
      style: const TextStyle(color: Colors.white),
      textInputAction:
          nextFocus != null ? TextInputAction.next : TextInputAction.done,
      onSubmitted: (value) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        } else {
          submitAction?.call();
        }
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[900],
        labelText: hint,
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
