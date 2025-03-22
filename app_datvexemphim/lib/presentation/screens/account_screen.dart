import 'package:app_datvexemphim/api/api_service.dart';
import 'package:flutter/material.dart';
import '../../data/services/storage_service.dart';
import 'package:go_router/go_router.dart';
import 'package:app_datvexemphim/presentation/screens/detailprofile_screen.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // title: const Text('Tài khoản',
        //     style: TextStyle(fontWeight: FontWeight.bold)),
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

  /// Giao diện Chưa đăng nhập
  Widget _buildGuestView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),

          // Logo
          Image.asset('assets/images/logofull2.png', height: 200),
          const SizedBox(height: 20),

          // Tiêu đề
          const Text(
            "Ohh, bạn chưa Đăng nhập !!\n Đăng Ký Thành Viên Star\nNhận Ngay Ưu Đãi!",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Danh sách lợi ích
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFeatureItem(Icons.star, "Stars"),
              _buildFeatureItem(Icons.card_giftcard, "Quà tặng"),
              _buildFeatureItem(Icons.emoji_events, "Ưu đãi"),
            ],
          ),
          const SizedBox(height: 40),

          // Nút Đăng ký & Đăng nhập
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push('/register'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Đăng ký",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push('/login'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: const BorderSide(color: Colors.red, width: 2),
                  ),
                  child: const Text(
                    "Đăng nhập",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Widget hiển thị từng lợi ích
  Widget _buildFeatureItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withOpacity(0.2),
          ),
          child: Icon(icon, size: 32, color: Colors.red),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  /// Giao diện nếu đã đăng nhập
  Widget _buildUserView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar & Thông tin user
          CircleAvatar(
            radius: 50,
            backgroundImage: userData?['hinhAnh'] != null
                ? NetworkImage(userData!['hinhAnh'])
                : null,
            backgroundColor: Colors.grey.shade300,
            child: userData?['hinhAnh'] == null
                ? const Icon(Icons.person, size: 50, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            userData?['hoTen'] ?? 'Người dùng',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text('Star Member',
              style: TextStyle(color: Colors.orange, fontSize: 16)),
          const SizedBox(height: 10),

          // Stars + Mã thành viên
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 20),
              const SizedBox(width: 5),
              const Text('0 Stars',
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade100,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            icon: const Icon(Icons.qr_code, color: Colors.red),
            label: const Text('Mã thành viên',
                style: TextStyle(color: Colors.red)),
          ),
          const SizedBox(height: 25),

          // Tính năng cá nhân
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoButton('Thông tin', Icons.edit, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DetailprofileScreen()),
                  );
                }),
                _buildInfoButton('Giao dịch', Icons.history, () {}),
                _buildInfoButton('Thông báo', Icons.notifications, () {}),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // Tổng chi tiêu
          const Text(
            'Tổng chi tiêu 2025',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: 0.0,
            backgroundColor: Colors.grey.shade300,
            color: Colors.red,
            minHeight: 8,
          ),
          const SizedBox(height: 5),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0đ', style: TextStyle(fontSize: 14)),
              Text('2,000,000đ', style: TextStyle(fontSize: 14)),
              Text('4,000,000đ', style: TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 20),

          // Chức năng khác
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFeatureButton('Đổi Quà', Icons.card_giftcard, Colors.red),
              _buildFeatureButton('My Rewards', Icons.redeem, Colors.green),
              _buildFeatureButton(
                  'Gói Hội Viên', Icons.workspace_premium, Colors.blue),
            ],
          ),
          const SizedBox(height: 20),

          // Hỗ trợ & thông tin
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.blue),
            title: const Text('Đường dây nóng: 19002224'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.email, color: Colors.blue),
            title: const Text('Email: hotro@atsh.vn'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.grey),
            title: const Text('Thông tin công ty'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.article, color: Colors.grey),
            title: const Text('Điều khoản sử dụng'),
            onTap: () {},
          ),
          const Divider(),

          Column(
            children: [
              // Nút Đăng Xuất
              SizedBox(
                width: double.infinity, // Kéo dài ngang màn hình
                child: OutlinedButton(
                  onPressed: () async {
                    bool? shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text("Xác nhận đăng xuất"),
                        content: const Text(
                            "Bạn có chắc chắn muốn đăng xuất không?"),
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

                    if (shouldLogout == true) {
                      await StorageService.clearUserData();
                      if (mounted) {
                        context.go('/onboarding');
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: const BorderSide(color: Colors.red), // Viền đỏ
                  ),
                  child: const Text(
                    "Đăng xuất",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red, // Màu chữ đỏ
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10), // Khoảng cách giữa hai nút

              // Nút Xóa Tài Khoản
              SizedBox(
                width: double.infinity, // Kéo dài ngang màn hình
                child: ElevatedButton(
                  onPressed: () async {
                    bool? shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text("Xác nhận xóa tài khoản"),
                        content: const Text(
                            "Bạn có chắc chắn muốn xóa tài khoản không? Hành động này không thể hoàn tác!"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Hủy"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              "Xóa tài khoản",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (shouldDelete == true) {
                      // Gọi API hoặc xử lý logic xóa tài khoản
                      //await StorageService.deleteUserAccount();

                      if (mounted) {
                        context.go(
                            '/onboarding'); // Chuyển về trang khởi động sau khi xóa tài khoản
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900, // Màu đỏ đậm hơn
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Xóa tài khoản",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Màu chữ trắng
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

// Widget chức năng cá nhân
  Widget _buildInfoButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 26, color: Colors.red),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

// Widget chức năng đổi quà, gói hội viên
  Widget _buildFeatureButton(String label, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, size: 30, color: color),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
