import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ cá nhân"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar + Tên + Email
            const CircleAvatar(
              radius: 50,
              backgroundImage:
                  AssetImage("assets/avatar.jpg"), // Thay ảnh avatar
            ),
            const SizedBox(height: 10),
            const Text(
              "Nguyễn Văn A",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text("nguyenvana@email.com",
                style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 20),

            // Danh sách cài đặt
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Chỉnh sửa hồ sơ"),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text("Đổi mật khẩu"),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text("Thông báo"),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text("Trợ giúp"),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Đăng xuất",
                        style: TextStyle(color: Colors.red)),
                    onTap: () {
                      // Xử lý đăng xuất
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
