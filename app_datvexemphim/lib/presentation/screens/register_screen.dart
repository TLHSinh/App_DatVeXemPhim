import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_datvexemphim/api/api_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _genderFocus = FocusNode();
  final FocusNode _imageFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register() async {
    setState(() => _errorMessage = null);

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = "Mật khẩu không khớp!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post("/register", {
        "email": _emailController.text.trim(),
        "matKhau": _passwordController.text.trim(),
        "hoTen": _fullNameController.text.trim(),
        "gioiTinh": _genderController.text.trim(),
        "hinhAnh": _imageController.text.trim(),
        "role": "user", // Mặc định role là "user"
      });

      if (response != null && response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Đăng ký thành công!")),
        );
        GoRouter.of(context).go('/login');
      } else {
        setState(() => _errorMessage = "Đăng ký thất bại, thử lại!");
      }
    } catch (e) {
      print("Lỗi API: $e");
      setState(() => _errorMessage = "⚠️ Lỗi server, thử lại sau!");
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _genderController.dispose();
    _imageController.dispose();
    _emailFocus.dispose();
    _fullNameFocus.dispose();
    _genderFocus.dispose();
    _imageFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
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
                child: Image.asset('assets/images/logofull.png', width: 100),
              ),
              SizedBox(height: 40),
              const Text(
                'Đăng ký',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 20),
              _buildTextField(_emailController, "Email",
                  focusNode: _emailFocus, nextFocus: _fullNameFocus),
              const SizedBox(height: 15),
              _buildTextField(_fullNameController, "Họ và tên",
                  focusNode: _fullNameFocus, nextFocus: _genderFocus),
              const SizedBox(height: 15),
              _buildTextField(_genderController, "Giới tính",
                  focusNode: _genderFocus, nextFocus: _imageFocus),
              const SizedBox(height: 15),
              _buildTextField(_imageController, "Link ảnh đại diện",
                  focusNode: _imageFocus, nextFocus: _passwordFocus),
              const SizedBox(height: 15),
              _buildTextField(_passwordController, "Mật khẩu",
                  isPassword: true,
                  focusNode: _passwordFocus,
                  nextFocus: _confirmPasswordFocus),
              const SizedBox(height: 15),
              _buildTextField(_confirmPasswordController, "Xác nhận mật khẩu",
                  isPassword: true,
                  focusNode: _confirmPasswordFocus,
                  submitAction: _register),
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
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'Đăng ký',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => GoRouter.of(context).go('/login'),
                  child: const Text(
                    "Bạn đã có tài khoản? Đăng nhập ngay",
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
