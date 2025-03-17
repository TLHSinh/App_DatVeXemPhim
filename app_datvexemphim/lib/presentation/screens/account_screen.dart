import 'package:app_datvexemphim/api/api_service.dart';
import 'package:app_datvexemphim/presentation/screens/home_screen.dart';
import 'package:app_datvexemphim/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../data/services/storage_service.dart';
import 'package:go_router/go_router.dart';
import 'package:app_datvexemphim/presentation/screens/detailprofile_screen.dart';
import '../presentation/screens/home_screen.dart';

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
    setState(() => isLoading = true);
    try {
      final response = await ApiService.get("/user/$userId");

      if (response?.statusCode == 200 && response?.data['success'] == true) {
        setState(() {
          userData = response?.data['data'];
        });
      }
    } catch (e) {
      print("❌ Lỗi lấy dữ liệu: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: token != null
            ? [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings),
                ),
              ]
            : null,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : token == null
              ? _buildGuestView(context)
              : _buildUserView(context),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.local_movies), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
        currentIndex: 2,
      ),
    );
  }

  /// Giao diện nếu chưa đăng nhập
  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline, size: 100, color: Colors.grey),
          const SizedBox(height: 10),
          const Text(
            "Bạn chưa đăng nhập",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.push('/login'),
            child: const Text("Đăng nhập"),
          ),
          TextButton(
            onPressed: () => context.push('/register'),
            child: const Text("Chưa có tài khoản? Đăng ký ngay"),
          ),
        ],
      ),
    );
  }

  /// Giao diện nếu đã đăng nhập
  Widget _buildUserView(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 40,
            backgroundImage: userData?['hinhAnh'] != null
                ? NetworkImage(userData!['hinhAnh'])
                : null,
            backgroundColor: Colors.grey,
          ),
          const SizedBox(height: 10),
          Text(
            userData?['hoTen'] ?? 'Người dùng',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text('Star', style: TextStyle(color: Colors.orange)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.card_giftcard, color: Colors.orange, size: 18),
              const SizedBox(width: 5),
              const Text('0 Stars', style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.qr_code, color: Colors.orange),
            label: const Text('Mã thành viên',
                style: TextStyle(color: Colors.orange)),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoButton('Thông tin', Icons.edit, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DetailprofileScreen()),
                  );
                }),
                Container(height: 40, width: 1, color: Colors.grey),
                _buildInfoButton('Giao dịch', Icons.history, () {}),
                Container(height: 40, width: 1, color: Colors.grey),
                _buildInfoButton('Thông báo', Icons.notifications, () {}),
              ],
            ),
          ),
          const Divider(thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tổng chi tiêu 2025',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const LinearProgressIndicator(value: 0.0),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0đ'),
                    Text('2,000,000đ'),
                    Text('4,000,000đ'),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFeatureButton('Đổi Quà', Icons.card_giftcard),
                    _buildFeatureButton('My Rewards', Icons.redeem),
                    _buildFeatureButton('Gói Hội Viên', Icons.diamond),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                ListTile(
                  title: const Text('Gọi ĐƯỜNG DÂY NÓNG: 19002224',
                      style: TextStyle(color: Colors.blue)),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('Email: hotro@atsh.vn',
                      style: TextStyle(color: Colors.blue)),
                  onTap: () {},
                ),
                ListTile(title: const Text('Thông Tin Công Ty'), onTap: () {}),
                ListTile(title: const Text('Điều Khoản Sử Dụng'), onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              bool? shouldLogout = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text("Xác nhận đăng xuất"),
                  content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Hủy"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("Đăng xuất"),
                    ),
                  ],
                ),
              );

              // Nếu người dùng xác nhận đăng xuất
              if (shouldLogout == true) {
                // Xóa dữ liệu người dùng
                await StorageService.clearUserData();

                if (mounted) {
                  // Điều hướng về màn hình Onboarding sau khi đăng xuất
                  if (mounted) {
                    context.go('/onboarding'); // Điều hướng về trang Onboarding
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              "Đăng xuất",
              style: TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static Widget _buildFeatureButton(String label, IconData icon) {
    return Column(
      children: [
        CircleAvatar(radius: 30, child: Icon(icon, size: 30)),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildInfoButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
