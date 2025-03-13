import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_datvexemphim/api/api_service.dart';

class PickCinemaAndTimeScreen extends StatefulWidget {
  final Map<String, dynamic> movie;

  const PickCinemaAndTimeScreen({Key? key, required this.movie}) : super(key: key);

  @override
  _PickCinemaAndTimeScreenState createState() => _PickCinemaAndTimeScreenState();
}

class _PickCinemaAndTimeScreenState extends State<PickCinemaAndTimeScreen> {
  List<dynamic> showtimes = [];
  bool isLoading = true;
  List<String> dates = [];
  String? selectedDate;

  @override
  void initState() {
    super.initState();
    fetchShowtimes();
  }

  Future<void> fetchShowtimes() async {
    try {
      final response = await ApiService.get("/book/lich-chieu/${widget.movie['_id']}");
      if (response?.statusCode == 200) {
        parseShowtimes(response?.data);
      }
    } catch (e) {
      print("❌ Lỗi khi lấy lịch chiếu: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void parseShowtimes(Map<String, dynamic>? data) {
    if (data == null || data['lich_chieu'] == null) return;

    showtimes = data['lich_chieu'];
    dates = showtimes
        .map<String?>((s) => _formatDate(s['thoi_gian_chieu']))
        .whereType<String>()
        .toSet()
        .toList();

    if (dates.isNotEmpty) {
      selectedDate = dates.first;
    }
  }

  String? _formatDate(String? dateTime) {
    if (dateTime?.isNotEmpty ?? false) {
      return DateFormat('dd/MM').format(DateTime.parse(dateTime!));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.movie['ten_phim'] ?? "Chọn Giờ Chiếu",
            style: TextStyle(color: Color(0xFF545454), fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 252, 234, 255),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dates.isNotEmpty)
              DatePickerHorizontal(
                dates: dates,
                selectedDate: selectedDate,
                onDateSelected: (date) => setState(() => selectedDate = date),
              ),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : showtimes.isEmpty
                    ? Center(child: Text("Không có lịch chiếu", style: TextStyle(color: Colors.black54)))
                    : Expanded(
                        child: ShowtimeList(
                          showtimes: showtimes,
                          selectedDate: selectedDate,
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------
// Widget chọn ngày ngang
// ------------------------------------
class DatePickerHorizontal extends StatelessWidget {
  final List<String> dates;
  final String? selectedDate;
  final Function(String) onDateSelected;

  const DatePickerHorizontal({
    Key? key,
    required this.dates,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  String getDayOfWeek(String date) {
    DateTime today = DateTime.now();
    
    // Thêm năm hiện tại vào ngày/tháng để tránh lỗi parse sai
    DateTime dateTime = DateFormat('dd/MM/yyyy').parse("$date/${today.year}");

    if (dateTime.day == today.day && dateTime.month == today.month) {
      return "Hôm nay";
    }

    List<String> weekdays = ["Chủ Nhật", "Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy"];
    return weekdays[dateTime.weekday];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80, // Tăng chiều cao để hiển thị ngày trong tuần
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: dates.map((date) {
          bool isSelected = date == selectedDate;
          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              width: 70, // Đảm bảo kích thước đồng đều
              margin: EdgeInsets.symmetric(horizontal: 8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isSelected ? Colors.blue : Colors.black12),
                boxShadow: isSelected ? [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 5)] : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getDayOfWeek(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        
      ),
    );
  }
  
}



// ------------------------------------
// Widget danh sách lịch chiếu theo rạp
// ------------------------------------
class ShowtimeList extends StatelessWidget {
  final List<dynamic> showtimes;
  final String? selectedDate;

  const ShowtimeList({Key? key, required this.showtimes, required this.selectedDate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final groupedShowtimes = <String, Map<String, List<dynamic>>>{};

    for (var s in showtimes) {
      String cinema = s['id_rap']?['ten_rap'] ?? "Không rõ rạp";
      String format = s['dinh_dang'] ?? "2D Phụ Đề";
      String? showtimeDate = _formatDate(s['thoi_gian_chieu']);

      if (selectedDate == showtimeDate) {
        groupedShowtimes.putIfAbsent(cinema, () => {}).putIfAbsent(format, () => []).add(s);
      }
    }

    return groupedShowtimes.isEmpty
        ? Center(child: Text("Không có lịch chiếu", style: TextStyle(color: Color(0xFF545454), fontWeight: FontWeight.bold)))
        : ListView(
            children: groupedShowtimes.entries.map((entry) {
              return ExpansionTile(
                title: Text(entry.key, style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                children: entry.value.entries.map((formatEntry) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatEntry.key, style: TextStyle(color: Color(0xFF545454), fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        ShowtimeGrid(showtimes: formatEntry.value),
                      ],
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          );
  }

  String? _formatDate(String? dateTime) {
    if (dateTime?.isNotEmpty ?? false) {
      return DateFormat('dd/MM').format(DateTime.parse(dateTime!));
    }
    return null;
  }
}

// ------------------------------------
// Widget giờ chiếu (xếp 3 cột)
// ------------------------------------
class ShowtimeGrid extends StatelessWidget {
  final List<dynamic> showtimes;

  const ShowtimeGrid({Key? key, required this.showtimes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: showtimes.length,
      itemBuilder: (context, index) {
        String formattedTime = _formatTime(showtimes[index]['thoi_gian_chieu']);

        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[850],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            // TODO: Chuyển sang chọn ghế
          },
          child: Text(formattedTime, style: TextStyle(color: Colors.white, fontSize: 16)),
        );
      },
    );
  }

  String _formatTime(String? time) {
    return time?.isNotEmpty ?? false ? DateFormat('HH:mm').format(DateTime.parse(time!)) : "??:??";
  }
}
