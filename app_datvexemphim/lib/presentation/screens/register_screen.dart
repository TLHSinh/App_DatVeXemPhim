import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_datvexemphim/api/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

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

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  Future<void> _register() async {
    setState(() => _errorMessage = null);

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = "Mật khẩu không khớp!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post("/auth/register", {
        "email": _emailController.text.trim(),
        "matKhau": _passwordController.text.trim(),
        "hoTen": _fullNameController.text.trim(),
        "gioiTinh": _genderController.text.trim(),
        "hinhAnh": _imageController.text.trim(),
        "role": "user",
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
      setState(() => _errorMessage = "⚠️ Lỗi server, thử lại sau!");
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
        prefixIcon: Icon(icon, color: Color(0xFFC20077)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Color(0xFFC20077),
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
                    'Đăng ký thành viên Star',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(_emailController, "Email", Icons.email),
                  const SizedBox(height: 15),
                  _buildTextField(_fullNameController, "Họ và tên", Icons.person),
                  const SizedBox(height: 15),
                  _buildTextField(_genderController, "Giới tính", Icons.wc),
                  const SizedBox(height: 15),
                  _buildTextField(_imageController, "Link ảnh đại diện", Icons.image),
                  const SizedBox(height: 15),
                  _buildTextField(_passwordController, "Mật khẩu", Icons.lock, isPassword: true),
                  const SizedBox(height: 15),
                  _buildTextField(_confirmPasswordController, "Xác nhận mật khẩu", Icons.lock, isPassword: true),
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
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Hoàn Tất',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => GoRouter.of(context).go('/login'),
              child: const Text(
                "Bạn đã có tài khoản? Đăng nhập ngay",
                style: TextStyle(
                    color: Colors.black, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
