import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../data/services/storage_service.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? token;
  String? userId;
  Map<String, dynamic>? userData;
  bool isLoading = true;

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
        });
      }
    } catch (e) {
      print("Lỗi lấy dữ liệu: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    await StorageService.clearUserData();
    if (mounted) {
      GoRouter.of(context).go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tài khoản",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : token == null
              ? _buildGuestView()
              : _buildUserView(),
    );
  }

  Widget _buildGuestView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/images/guest_profile.png', height: 120),
          const SizedBox(height: 20),
          const Text(
            "Đăng Ký Thành Viên Star\nNhận Ngay Ưu Đãi!",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => GoRouter.of(context).go('/register'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text("Đăng ký",
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => GoRouter.of(context).go('/login'),
                child: const Text("Đăng nhập"),
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildGuestOptions(),
        ],
      ),
    );
  }

  Widget _buildGuestOptions() {
    return Column(
      children: [
        _buildInfoTile(Icons.phone, "Gọi ĐƯỜNG DÂY NÓNG: 19002224"),
        _buildInfoTile(Icons.email, "Email: hotro@galaxystudio.vn"),
        _buildSettingsOption("Thông Tin Công Ty"),
        _buildSettingsOption("Điều Khoản Sử Dụng"),
        _buildSettingsOption("Chính Sách Thanh Toán"),
        _buildSettingsOption("Chính Sách Bảo Mật"),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(text),
    );
  }

  Widget _buildSettingsOption(String title) {
    return ListTile(
      leading:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
      title: Text(title),
      onTap: () {},
    );
  }

  Widget _buildUserView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                  userData!['hinhAnh'] ?? "https://via.placeholder.com/150"),
            ),
          ),
          const SizedBox(height: 20),
          _buildUserInfo("Họ và Tên", userData!['hoTen']),
          _buildUserInfo("Email", userData!['email']),
          _buildUserInfo("Giới tính", userData!['gioiTinh']),
          _buildUserInfo("Điểm tích lũy", userData!['diemTichLuy'].toString()),
          _buildUserInfo(
              "Trạng thái", userData!['trangThai'] ? 'Hoạt động' : 'Bị khóa'),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Đăng xuất",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Text("$title:",
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Text(value, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
