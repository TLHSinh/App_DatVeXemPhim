import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.settings, color: Colors.blue),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircleAvatar(radius: 40, backgroundColor: Colors.grey),
            SizedBox(height: 10),
            Text('Trịnh Lê Hồng Sinh',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Star', style: TextStyle(color: Colors.orange)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.card_giftcard, color: Colors.orange, size: 18),
                SizedBox(width: 5),
                Text('0 Stars', style: TextStyle(color: Colors.grey)),
              ],
            ),
            SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.qr_code, color: Colors.orange),
              label:
                  Text('Mã thành viên', style: TextStyle(color: Colors.orange)),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoButton('Thông tin', Icons.edit),
                  Container(height: 40, width: 1, color: Colors.grey),
                  _buildInfoButton('Giao dịch', Icons.history),
                  Container(height: 40, width: 1, color: Colors.grey),
                  _buildInfoButton('Thông báo', Icons.notifications),
                ],
              ),
            ),
            Divider(thickness: 1),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tổng chi tiêu 2025',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  LinearProgressIndicator(value: 0.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('0đ'),
                      Text('2,000,000đ'),
                      Text('4,000,000đ'),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFeatureButton('Đổi Quà', Icons.card_giftcard),
                      _buildFeatureButton('My Rewards', Icons.redeem),
                      _buildFeatureButton('Gói Hội Viên', Icons.diamond),
                    ],
                  ),
                  SizedBox(height: 20),
                  Divider(),
                  ListTile(
                    title: Text('Gọi ĐƯỜNG DÂY NÓNG: 19002224',
                        style: TextStyle(color: Colors.blue)),
                    onTap: () {},
                  ),
                  ListTile(
                    title: Text('Email: hotro@galaxystudio.vn',
                        style: TextStyle(color: Colors.blue)),
                    onTap: () {},
                  ),
                  ListTile(
                    title: Text('Thông Tin Công Ty'),
                    onTap: () {},
                  ),
                  ListTile(
                    title: Text('Điều Khoản Sử Dụng'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildFeatureButton(String label, IconData icon) {
    return Column(
      children: [
        CircleAvatar(radius: 30, child: Icon(icon, size: 30)),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildInfoButton(String label, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Đảm bảo chiều rộng là vừa đủ
      children: [
        Icon(icon, size: 20),
        SizedBox(width: 8), // Khoảng cách giữa icon và text
        Text(label),
      ],
    );
  }
}
