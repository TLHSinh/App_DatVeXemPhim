import 'dart:io';

import 'package:app_datvexemphim/utils/cloudinary_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_datvexemphim/api/api_service.dart';
import 'package:image_picker/image_picker.dart';

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
  File? _selectedImage;
  bool _isUploadingImage = false;

  // Màn hình Đăng Ký
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
          const SnackBar(
              content: Text("✅ Đăng ký thành công! Vui lòng nhập OTP.")),
        );
        GoRouter.of(context)
            .push('/verify-otp', extra: _emailController.text.trim());
      } else {
        setState(() => _errorMessage = "Đăng ký thất bại, thử lại!");
      }
    } catch (e) {
      setState(() => _errorMessage = "⚠️ Lỗi server, thử lại sau!");
    }

    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _isUploadingImage = true;
      });

      try {
        // Upload ảnh lên Cloudinary
        final cloudinary = CloudinaryService();
        final imageUrl = await cloudinary.uploadImage(_selectedImage!);

        if (imageUrl != null) {
          _imageController.text = imageUrl;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("❌ Lỗi upload ảnh đại diện")));
        }
      } catch (e) {
        print("Lỗi upload ảnh: $e");
      } finally {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  // Widget _buildTextField(
  //     TextEditingController controller, String hint, IconData icon,
  //     {bool isPassword = false}) {
  //   return TextField(
  //     controller: controller,
  //     obscureText: isPassword ? _obscurePassword : false,
  //     style: const TextStyle(color: Colors.black),
  //     decoration: InputDecoration(
  //       filled: true,
  //       fillColor: Colors.white,
  //       labelText: hint,
  //       labelStyle: const TextStyle(color: Color(0xFF545454)),
  //       prefixIcon: Icon(icon, color: Color(0xFFee0033)),
  //       suffixIcon: isPassword
  //           ? IconButton(
  //               icon: Icon(
  //                 _obscurePassword ? Icons.visibility_off : Icons.visibility,
  //                 color: Color(0xFFee0033),
  //               ),
  //               onPressed: () {
  //                 setState(() {
  //                   _obscurePassword = !_obscurePassword;
  //                 });
  //               },
  //             )
  //           : null,
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(8),
  //         borderSide: const BorderSide(color: Color(0xFFee0033)),
  //       ),
  //     ),
  //   );
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       backgroundColor: Colors.white,
  //       elevation: 0,
  //       leading: IconButton(
  //         icon: Icon(Icons.arrow_back, color: Colors.black),
  //         onPressed: () => GoRouter.of(context).go('/home'),
  //       ),
  //       centerTitle: true,
  //     ),
  //     backgroundColor: Colors.white,
  //     body: LayoutBuilder(
  //       builder: (context, constraints) {
  //         return SingleChildScrollView(
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Center(
  //                   child:
  //                       Image.asset('assets/images/logofull2.png', width: 500),
  //                 ),
  //                 const SizedBox(height: 40),
  //                 const Text(
  //                   'Đăng ký thành viên Star',
  //                   style: TextStyle(
  //                       fontSize: 24,
  //                       fontWeight: FontWeight.bold,
  //                       color: Colors.black),
  //                 ),
  //                 const SizedBox(height: 20),

  //                 GestureDetector(
  //                   onTap: _pickImage,
  //                   child: Container(
  //                       height: 100,
  //                       decoration: BoxDecoration(
  //                         color: Colors.grey[200],
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                       child: _selectedImage != null
  //                           ? Stack(
  //                               children: [
  //                                 Image.file(_selectedImage!,
  //                                     fit: BoxFit.cover,
  //                                     width: double.infinity),
  //                                 if (_isUploadingImage)
  //                                   const Center(
  //                                     child: CircularProgressIndicator(),
  //                                   )
  //                               ],
  //                             )
  //                           : Column(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: const [
  //                                 Icon(Icons.camera_alt,
  //                                     color: Colors.grey, size: 40),
  //                                 Text(
  //                                   "Thêm ảnh đại diện",
  //                                   style: TextStyle(color: Colors.grey),
  //                                 )
  //                               ],
  //                             )),
  //                 ),

  //                 _buildTextField(_emailController, "Email", Icons.email),
  //                 const SizedBox(height: 15),
  //                 _buildTextField(
  //                     _fullNameController, "Họ và tên", Icons.person),
  //                 const SizedBox(height: 15),
  //                 _buildTextField(_genderController, "Giới tính", Icons.wc),
  //                 const SizedBox(height: 15),
  //                 // _buildTextField(
  //                 //     _imageController, "Link ảnh đại diện", Icons.image),
  //                 const SizedBox(height: 15),
  //                 _buildTextField(_passwordController, "Mật khẩu", Icons.lock,
  //                     isPassword: true),
  //                 const SizedBox(height: 15),
  //                 _buildTextField(_confirmPasswordController,
  //                     "Xác nhận mật khẩu", Icons.lock,
  //                     isPassword: true),
  //                 const SizedBox(height: 10),
  //                 _errorMessage != null
  //                     ? Text(_errorMessage!,
  //                         style:
  //                             const TextStyle(color: Colors.red, fontSize: 14))
  //                     : const SizedBox.shrink(),
  //                 const SizedBox(height: 25),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //     bottomNavigationBar: Container(
  //       color: const Color.fromARGB(255, 255, 243, 243),
  //       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           SizedBox(
  //             width: double.infinity,
  //             height: 50,
  //             child: ElevatedButton(
  //               onPressed: _register,
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.redAccent,
  //                 foregroundColor: Colors.white,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //               ),
  //               child: _isLoading
  //                   ? const CircularProgressIndicator(color: Colors.white)
  //                   : const Text(
  //                       'Hoàn Tất',
  //                       style: TextStyle(
  //                           fontSize: 18, fontWeight: FontWeight.bold),
  //                     ),
  //             ),
  //           ),
  //           const SizedBox(height: 10),
  //           GestureDetector(
  //             onTap: () => GoRouter.of(context).go('/login'),
  //             child: const Text(
  //               "Bạn đã có tài khoản? Đăng nhập ngay",
  //               style: TextStyle(color: Colors.black, fontSize: 16),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFEE0033);
    final Color lightPrimaryColor = primaryColor.withOpacity(0.1);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => GoRouter.of(context).go('/home'),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child:
                        Image.asset('assets/images/logofull2.png', width: 200),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: lightPrimaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: primaryColor, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Đăng ký thành viên Star',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Đăng ký để nhận nhiều ưu đãi hấp dẫn',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Avatar selector
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                          border: Border.all(color: Color(0xffb5b5b5), width: 2),
                        ),
                        child: _selectedImage != null
                            ? ClipOval(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                    ),
                                    if (_isUploadingImage)
                                      Container(
                                        color: Colors.black38,
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt,
                                      color: primaryColor, size: 40),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Thêm ảnh đại diện",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form fields
                  _buildTextField(
                      _emailController, "Email", Icons.email, primaryColor),
                  const SizedBox(height: 16),
                  _buildTextField(_fullNameController, "Họ và tên",
                      Icons.person, primaryColor),
                  const SizedBox(height: 16),
                  _buildGenderDropdown(primaryColor),
                  const SizedBox(height: 16),
                  _buildTextField(
                      _passwordController, "Mật khẩu", Icons.lock, primaryColor,
                      isPassword: true),
                  const SizedBox(height: 16),
                  _buildTextField(_confirmPasswordController,
                      "Xác nhận mật khẩu", Icons.lock, primaryColor,
                      isPassword: true),

                  const SizedBox(height: 12),
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
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
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'ĐĂNG KÝ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => GoRouter.of(context).go('/login'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Bạn đã có tài khoản? ",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    "Đăng nhập ngay",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, Color primaryColor,
      {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: primaryColor),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

// Widget Dropdown cho giới tính
  Widget _buildGenderDropdown(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _genderController.text.isEmpty ? null : _genderController.text,
        decoration: InputDecoration(
          labelText: "Giới tính",
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(Icons.wc, color: primaryColor),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        items: const [
          DropdownMenuItem(
            value: "nam",
            child: Text("Nam"),
          ),
          DropdownMenuItem(
            value: "nu",
            child: Text("Nữ"),
          ),
          DropdownMenuItem(
            value: "khac",
            child: Text("Khác"),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            _genderController.text = value;
          }
        },
        icon: Icon(Icons.arrow_drop_down, color: primaryColor),
      ),
    );
  }
}
