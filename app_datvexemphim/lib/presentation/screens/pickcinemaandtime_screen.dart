import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'package:app_datvexemphim/api/api_service.dart';

class PickCinemaAndTimeScreen extends StatefulWidget {
  final Map<String, dynamic> movie;

  const PickCinemaAndTimeScreen({Key? key, required this.movie})
      : super(key: key);

  @override
  _PickCinemaAndTimeScreenState createState() =>
      _PickCinemaAndTimeScreenState();
}

class _PickCinemaAndTimeScreenState extends State<PickCinemaAndTimeScreen> {
  List<dynamic> showtimes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchShowtimes();
  }

  Future<void> fetchShowtimes() async {
    setState(() => isLoading = true);
    try {
      final response =
          await ApiService.get("/book/lich-chieu/${widget.movie['_id']}");

      if (response?.statusCode == 200 &&
          response?.data is Map<String, dynamic>) {
        var data = response?.data as Map<String, dynamic>;
        setState(() => showtimes = data['lich_chieu'] ?? []);
      } else {
        setState(() => showtimes = []);
      }
    } catch (e) {
      print("❌ Lỗi khi lấy lịch chiếu: $e");
      setState(() => showtimes = []);
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text("Chọn Rạp & Giờ Chiếu"),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : showtimes.isEmpty
              ? Center(
                  child: Text("Không có lịch chiếu",
                      style: TextStyle(color: Colors.white70)))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: showtimes.length,
                  itemBuilder: (context, index) {
                    var showtime = showtimes[index];
                    return ShowtimeCard(showtime: showtime);
                  },
                ),
    );
  }
}

class ShowtimeCard extends StatelessWidget {
  final Map<String, dynamic> showtime;

  const ShowtimeCard({Key? key, required this.showtime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String cinemaName = showtime['id_rap']?['ten_rap'] ?? "Không rõ rạp";
    String roomName = showtime['id_phong']?['ten_phong'] ?? "Không rõ phòng";
    String price = "${showtime['gia_ve'] ?? 0} VND";
    String time = showtime['thoi_gian_chieu'] ?? "";
    String formattedTime = time.isNotEmpty
        ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(time))
        : "Không rõ thời gian";

    return Card(
      color: Colors.grey[850],
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cinemaName,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            SizedBox(height: 8),
            Text("Phòng: $roomName", style: TextStyle(color: Colors.white70)),
            Text("Giờ chiếu: $formattedTime",
                style: TextStyle(color: Colors.white70)),
            Text("Giá vé: $price",
                style: TextStyle(
                    color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Điều hướng đến trang chọn ghế
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("Chọn", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
