import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'select_seat_screen.dart';
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
  List<dynamic> cinemas = [];
  List<dynamic> showtimes = [];
  String? selectedCinemaId;
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      final responses = await Future.wait([
        ApiService.get("/rapphims"),
        ApiService.get("/lich-chieu/${widget.movie['id']}")
      ]);

      if (responses[0]?.statusCode == 200 && responses[1]?.statusCode == 200) {
        List<dynamic> allCinemas = responses[0]?.data ?? [];
        List<dynamic> showtimesData = responses[1]?.data ?? [];

        cinemas = allCinemas
            .where((cinema) => showtimesData
                .any((showtime) => showtime["idRap"] == cinema["id"]))
            .toList();
      }
    } catch (e) {
      print("Lỗi khi lấy dữ liệu: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> fetchShowtimes() async {
    if (selectedCinemaId == null) return;

    setState(() => isLoading = true);
    try {
      final response = await ApiService.post("lich-chieu/ngay", {
        "idPhim": widget.movie["id"],
        "idRap": selectedCinemaId,
        "ngayChieu": DateFormat('yyyy-MM-dd').format(selectedDate)
      });

      if (response != null &&
          response.statusCode == 200 &&
          response.data is List) {
        setState(() {
          showtimes = response.data;
          isLoading = false;
        });
      } else {
        throw Exception("Dữ liệu trả về không hợp lệ");
      }
    } catch (e) {
      print("🔥 Lỗi khi lấy lịch chiếu: $e");
      setState(() {
        showtimes = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff212121),
      appBar: AppBar(
          title: Text("Chọn Rạp & Thời Gian"), backgroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(widget.movie["ten_phim"] ?? "Không có tên"),
                  SizedBox(height: 20),
                  _buildDropdown("Chọn rạp", cinemas, selectedCinemaId,
                      (value) {
                    setState(() {
                      selectedCinemaId = value;
                      showtimes = [];
                    });
                    fetchShowtimes();
                  }),
                  SizedBox(height: 20),
                  _buildDatePicker(),
                  SizedBox(height: 20),
                  _buildShowtimeButtons(),
                ],
              ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDropdown(String label, List<dynamic> items, String? value,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white, fontSize: 18)),
        SizedBox(height: 10),
        DropdownButton<String>(
          value: value,
          dropdownColor: Colors.black,
          hint: Text("Chọn rạp", style: TextStyle(color: Colors.white)),
          icon: Icon(Icons.arrow_drop_down, color: Colors.white),
          items: items.map((cinema) {
            return DropdownMenuItem<String>(
              value: cinema["id"].toString(),
              child: Text(cinema["ten_rap"],
                  style: TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Chọn ngày", style: TextStyle(color: Colors.white, fontSize: 18)),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 14)),
            );
            if (picked != null && picked != selectedDate) {
              setState(() {
                selectedDate = picked;
                showtimes = [];
              });
              fetchShowtimes();
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text(DateFormat('dd/MM/yyyy').format(selectedDate),
              style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildShowtimeButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Chọn suất chiếu",
            style: TextStyle(color: Colors.white, fontSize: 18)),
        SizedBox(height: 10),
        showtimes.isEmpty
            ? Text("Không có suất chiếu",
                style: TextStyle(color: Colors.white70))
            : Wrap(
                spacing: 10,
                children: showtimes.map((showtime) {
                  return ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SelectSeatScreen(showtime: showtime),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800]),
                    child: Text(showtime["gio_chieu"],
                        style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
              ),
      ],
    );
  }
}
