import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../data/services/storage_service.dart';
import 'package:go_router/go_router.dart';

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
    try {
      final response = await Dio().get(
        "http://localhost:5000/api/v1/user/$userId",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          userData = response.data['data'];
          _nameController.text = userData!["hoTen"] ?? "";
          _emailController.text = userData!["email"] ?? "";
          _phoneController.text = userData!["sodienthoai"] ?? "";
          _dobController.text = userData!["ngaySinh"] ?? "";
          _cccdController.text = userData!["cccd"] ?? "";
          _genderController.text = userData!["gioiTinh"] ?? "";
          _addressController.text = userData!["diaChi"] ?? "";
        });
      }
    } catch (e) {
      print("Lỗi lấy dữ liệu: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateUserData() async {
    try {
      final response = await Dio().put(
        "http://localhost:5000/api/v1/user/$userId",
        data: {
          "hoTen": _nameController.text,
          "sodienthoai": _phoneController.text,
          "ngaySinh": _dobController.text,
          "cccd": _cccdController.text,
          "gioiTinh": _genderController.text,
          "diaChi": _addressController.text,
        },
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật thành công!")),
        );
      }
    } catch (e) {
      print("Lỗi cập nhật dữ liệu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chỉnh sửa thông tin")),
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
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(userData?["hinhAnh"] ?? ""),
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
          Center(
            child: ElevatedButton(
              onPressed: _updateUserData,
              child: const Text("Lưu thông tin"),
            ),
          ),
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
