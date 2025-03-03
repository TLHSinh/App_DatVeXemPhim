import 'package:flutter/material.dart';

class DetailmovieScreen extends StatelessWidget {
  final Map<String, dynamic> movie;

const DetailmovieScreen({Key? key, required this.movie}) : super(key: key);

@override
  Widget build(BuildContext context) {
    String imageBaseUrl = "https://rapchieuphim.com";
    String fullImageUrl = imageBaseUrl + (movie["url_poster"] ?? "");

    return Scaffold(
      backgroundColor: const Color(0xff1B1B1B),
      appBar: AppBar(title: Text(movie["ten_phim"] ?? "Chi Tiết Phim")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(15),
            //   child: Image.network(
            //     fullImageUrl,
            //     width: double.infinity,
            //     height: 350,
            //     fit: BoxFit.cover,
            //     errorBuilder: (context, error, stackTrace) {
            //       return Image.network("https://via.placeholder.com/300", fit: BoxFit.cover);
            //     },
            //   ),
            // ),
            SizedBox(height: 16),
            Text(
              movie["ten_phim"] ?? "Không có tên",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              movie["mo_ta"] ?? "Không có mô tả",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                SizedBox(width: 5),
                Text(
                  "Ngày chiếu: ${movie["ngay_chieu"] ?? "Không rõ"}",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
