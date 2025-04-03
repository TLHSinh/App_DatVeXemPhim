import 'dart:io';
import 'package:app_datvexemphim/api/api_service.dart';
import 'package:app_datvexemphim/utils/cloudinary_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:app_datvexemphim/data/services/storage_service.dart';
import 'package:file_picker/file_picker.dart';

class DetailprofileScreen extends StatefulWidget {
  const DetailprofileScreen({super.key});

  @override
  State<DetailprofileScreen> createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends State<DetailprofileScreen> {
  String? token;
  String? userId;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  File? _selectedImage;
  // final picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _cccdController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    token = await StorageService.getToken();
    userId = await StorageService.getUserId();
    if (token == null || userId == null) {
      setState(() => isLoading = false);
      return;
    }
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.get("/user/$userId");

      if (response?.statusCode == 200 &&
          response?.data is Map<String, dynamic>) {
        var data = response?.data as Map<String, dynamic>;
        if (data['success'] == true) {
          setState(() {
            userData = data['data'];
            _nameController.text = userData?["hoTen"] ?? "";
            _emailController.text = userData?["email"] ?? "";
            _phoneController.text = userData?["sodienthoai"] ?? "";
            _dobController.text = userData?["ngaySinh"] ?? "";
            _cccdController.text = userData?["cccd"] ?? "";
            _genderController.text = userData?["gioiTinh"] ?? "";
            _addressController.text = userData?["diaChi"] ?? "";
          });
        }
      }
    } catch (e) {
      print("❌ Lỗi lấy dữ liệu người dùng: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> _updateUserData(String? imageUrl) async {
    try {
      final response = await ApiService.put(
        "/user/$userId",
        {
          "hoTen": _nameController.text,
          "sodienthoai": _phoneController.text,
          "ngaySinh": _dobController.text,
          "cccd": _cccdController.text,
          "gioiTinh": _genderController.text,
          "diaChi": _addressController.text,
          if (imageUrl != null) "hinhAnh": imageUrl,
        },
      );
      if (response?.statusCode == 200 && response?.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Cập nhật thành công!")),
        );
      }
    } catch (e) {
      print("❌ Lỗi cập nhật dữ liệu: $e");
    }
  }

  // // Hàm upload ảnh lên Cloudinary
  // Future<String?> _uploadImage (File file ) async {
  //   // String cloudinaryUrl = "https://api.cloudinary.com/v1_1/app-datvexemphim/image/upload";
  //   // String uploadPreset = "YOUR_UPLOAD_PRESET"; // Lấy từ Cloudinary

  //   try {
  //     FormData formData = FormData.fromMap({
  //       "hinhAnh": await MultipartFile.fromFile(file.path),
  //       // "upload_preset": uploadPreset,
  //     });

  //     final response = await ApiService.post("/uploadImg", formData);

  //      if (response?.statusCode == 200 && response?.data["secure_url"] != null) {
  //       return response?.data["secure_url"];
  //     }
  //   } catch (e) {
  //     print("Lỗi upload ảnh: $e");

  //   }
  // }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      print("Ảnh đã chọn: ${_selectedImage!.path}");
    } else {
      print("Người dùng chưa chọn ảnh.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      appBar: AppBar(
        title: const Text("Chỉnh sửa thông tin",
            style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xfff9f9f9),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildUserView(),
    );
  }

  Widget _buildUserView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : (userData?["hinhAnh"] != null
                              ? NetworkImage(userData!["hinhAnh"])
                              : const AssetImage("assets/default_avatar.png"))
                          as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.blue),
                    onPressed: _pickImage,
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                String? imageUrl;
                if (userData?["hinhAnh"] != null) {
                  final cloudinary = CloudinaryService();
                  imageUrl = await cloudinary.uploadImage(_selectedImage!);
                } else {
                  print("Không có ảnh nào để cập nhật.");
                }

                await _updateUserData(imageUrl ?? userData?["hinhAnh"]);
              },
              child: const Text("Lưu thông tin"),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField("Họ và Tên", _nameController),
          _buildTextField("Email", _emailController, enabled: false),
          _buildTextField("Số điện thoại", _phoneController),
          _buildTextField("Ngày sinh", _dobController),
          _buildTextField("CCCD", _cccdController),
          _buildTextField("Giới tính", _genderController),
          _buildTextField("Địa chỉ", _addressController),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        enabled: enabled,
      ),
    );
  }
}
