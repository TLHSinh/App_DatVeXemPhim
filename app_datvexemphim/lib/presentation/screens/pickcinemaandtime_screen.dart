import 'package:app_datvexemphim/presentation/screens/pickseat_screen.dart';
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
  List<DateTime> dates = [];
  DateTime? selectedDate;
  Map<String, bool> expandedCinemas = {}; // Track expanded cinemas

  @override
  void initState() {
    super.initState();
    _initializeDates();
    fetchShowtimes();
  }

  void _initializeDates() {
    DateTime today = DateTime.now();
    dates = List.generate(7, (index) => today.add(Duration(days: index)));
    selectedDate = dates.first;
  }

  Future<void> fetchShowtimes() async {
    try {
      final response = await ApiService.get("/book/lich-chieu/${widget.movie['_id']}");
      if (response?.statusCode == 200) {
        setState(() => showtimes = response?.data['lich_chieu'] ?? []);
      }
    } catch (e) {
      print("❌ Lỗi khi lấy lịch chiếu: $e");
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
        title: Text(widget.movie['ten_phim'] ?? "Chọn Giờ Chiếu",
            style: TextStyle(color: Color(0xFF545454), fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DatePickerHorizontal(
              dates: dates,
              selectedDate: selectedDate,
              onDateSelected: (date) => setState(() => selectedDate = date),
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: showtimes.isEmpty || !_hasShowtimesForSelectedDate()
                        ? Center(child: Text("Không có lịch chiếu cho ngày này"))
                        : ShowtimeList(
                            showtimes: showtimes,
                            selectedDate: selectedDate,
                            expandedCinemas: expandedCinemas,
                            toggleCinema: (cinema) {
                              setState(() {
                                expandedCinemas[cinema] = !(expandedCinemas[cinema] ?? false);
                              });
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }

  bool _hasShowtimesForSelectedDate() {
    return showtimes.any((s) {
      DateTime showDate = DateTime.parse(s['thoi_gian_chieu']);
      return selectedDate != null &&
          showDate.year == selectedDate!.year &&
          showDate.month == selectedDate!.month &&
          showDate.day == selectedDate!.day;
    });
  }
}

class DatePickerHorizontal extends StatelessWidget {
  final List<DateTime> dates;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const DatePickerHorizontal({
    Key? key,
    required this.dates,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: dates.map((date) {
          bool isSelected = date == selectedDate;
          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              width: 55,
              margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: isSelected ? Colors.red : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E', 'vi').format(date),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black54),
                  ),
                  SizedBox(height: 5),
                  Text(
                    DateFormat('dd').format(date),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black),
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

class ShowtimeList extends StatelessWidget {
  final List<dynamic> showtimes;
  final DateTime? selectedDate;
  final Map<String, bool> expandedCinemas;
  final Function(String) toggleCinema;

  const ShowtimeList({
    Key? key,
    required this.showtimes,
    required this.selectedDate,
    required this.expandedCinemas,
    required this.toggleCinema,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, List<dynamic>> groupedShowtimes = {};
    for (var s in showtimes) {
      DateTime showDate = DateTime.parse(s['thoi_gian_chieu']);
      if (selectedDate != null &&
          showDate.year == selectedDate!.year &&
          showDate.month == selectedDate!.month &&
          showDate.day == selectedDate!.day) {
        String cinemaName = s['id_rap']['ten_rap'] ?? "Không rõ rạp";
        if (!groupedShowtimes.containsKey(cinemaName)) {
          groupedShowtimes[cinemaName] = [];
        }
        groupedShowtimes[cinemaName]!.add(s);
      }
    }

    return ListView(
      children: groupedShowtimes.entries.map((entry) {
        bool isExpanded = expandedCinemas[entry.key] ?? false;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => toggleCinema(entry.key),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
            AnimatedSize(
              duration: Duration(milliseconds: 300),
              child: isExpanded
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Wrap(
                        spacing: 15,
                        runSpacing: 10,
                        children: entry.value.map((s) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PickseatScreen(schedule: s)),
                            ),
                            child: Text(DateFormat('HH:mm').format(DateTime.parse(s['thoi_gian_chieu'])), style: TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                      ),
                    )
                  : SizedBox(),
            ),
            SizedBox(height: 15),
          ],
        );
      }).toList(),
    );
  }
}
