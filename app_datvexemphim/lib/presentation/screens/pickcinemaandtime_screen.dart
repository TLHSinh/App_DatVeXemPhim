import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  String? selectedDate;

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
        showtimes = data['lich_chieu'] ?? [];

        // Lấy danh sách ngày chiếu và mặc định chọn ngày đầu tiên
        List<String> dates = showtimes
            .map((s) {
              String time = s['thoi_gian_chieu'] ?? "";
              return time.isNotEmpty
                  ? DateFormat('dd/MM').format(DateTime.parse(time))
                  : "";
            })
            .toSet()
            .toList();

        if (dates.isNotEmpty) {
          selectedDate = dates.first; // Chọn ngày đầu tiên
        }
      } else {
        showtimes = [];
      }
    } catch (e) {
      print("❌ Lỗi khi lấy lịch chiếu: $e");
      showtimes = [];
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    List<String> dates = showtimes
        .map((s) {
          String time = s['thoi_gian_chieu'] ?? "";
          return time.isNotEmpty
              ? DateFormat('dd/MM').format(DateTime.parse(time))
              : "";
        })
        .toSet()
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.movie['ten_phim'] ?? "Chọn Giờ Chiếu",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white), // Mũi tên Back màu trắng
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chọn ngày chiếu
            DatePickerHorizontal(
              dates: dates,
              selectedDate: selectedDate,
              onDateSelected: (date) => setState(() => selectedDate = date),
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : showtimes.isEmpty
                    ? Center(
                        child: Text("Không có lịch chiếu",
                            style: TextStyle(color: Colors.white70)))
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          bool isSelected = dates[index] == selectedDate;
          return GestureDetector(
            onTap: () => onDateSelected(dates[index]),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.redAccent : Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  dates[index],
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
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

  const ShowtimeList({
    Key? key,
    required this.showtimes,
    required this.selectedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, List<dynamic>>> groupedShowtimes = {};

    for (var s in showtimes) {
      String cinema = s['id_rap']?['ten_rap'] ?? "Không rõ rạp";
      String format = s['dinh_dang'] ?? "2D";
      String showtimeDate = DateFormat('dd/MM')
          .format(DateTime.parse(s['thoi_gian_chieu'] ?? ""));
      if (selectedDate == null || showtimeDate == selectedDate) {
        groupedShowtimes
            .putIfAbsent(cinema, () => {})
            .putIfAbsent(format, () => [])
            .add(s);
      }
    }

    return groupedShowtimes.isEmpty
        ? Center(
            child: Text("Không có lịch chiếu",
                style: TextStyle(color: Colors.white70)))
        : ListView(
            children: groupedShowtimes.entries.map((entry) {
              return ExpansionTile(
                title: Text(entry.key,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                children: entry.value.entries.map((formatEntry) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatEntry.key,
                            style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
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
        crossAxisCount: 3, // Mỗi hàng 3 giờ chiếu
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: showtimes.length,
      itemBuilder: (context, index) {
        String time = showtimes[index]['thoi_gian_chieu'] ?? "";
        String formattedTime = time.isNotEmpty
            ? DateFormat('HH:mm').format(DateTime.parse(time))
            : "??:??";

        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[850],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            // TODO: Chuyển sang chọn ghế
          },
          child: Text(formattedTime,
              style: TextStyle(color: Colors.white, fontSize: 16)),
        );
      },
    );
  }
}
