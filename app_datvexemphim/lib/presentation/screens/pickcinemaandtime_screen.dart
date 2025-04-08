import 'package:app_datvexemphim/presentation/screens/login_screen.dart';
import 'package:app_datvexemphim/presentation/screens/pickseat_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_datvexemphim/api/api_service.dart';
import '../../data/services/storage_service.dart';
import 'package:go_router/go_router.dart';
import 'package:app_datvexemphim/presentation/screens/detailprofile_screen.dart';

class PickCinemaAndTimeScreen extends StatefulWidget {
  final Map<String, dynamic> movie;

  const PickCinemaAndTimeScreen({super.key, required this.movie});

  @override
  _PickCinemaAndTimeScreenState createState() =>
      _PickCinemaAndTimeScreenState();
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
      final response =
          await ApiService.get("/book/lich-chieu/${widget.movie['_id']}");
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
            style: TextStyle(
                color: Color(0xFF545454), fontWeight: FontWeight.bold)),
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
                        ? Center(
                            child: Text("Không có lịch chiếu cho ngày này"))
                        : ShowtimeList(
                            showtimes: showtimes,
                            selectedDate: selectedDate,
                            expandedCinemas: expandedCinemas,
                            toggleCinema: (cinema) {
                              setState(() {
                                expandedCinemas[cinema] =
                                    !(expandedCinemas[cinema] ?? false);
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
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.onDateSelected,
  });

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
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black54),
                  ),
                  SizedBox(height: 5),
                  Text(
                    DateFormat('dd').format(date),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black),
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

//Fix lỗi cho Sinh
class ShowtimeList extends StatelessWidget {
  final List<dynamic> showtimes;
  final DateTime? selectedDate;
  final Map<String, bool> expandedCinemas;
  final Function(String) toggleCinema;

  const ShowtimeList({
    super.key,
    required this.showtimes,
    required this.selectedDate,
    required this.expandedCinemas,
    required this.toggleCinema,
  });

  String calculateEndTime(String fullStartTime, int duration) {
    try {
      final start = DateTime.parse(fullStartTime); // GIỮ NGUYÊN
      final end = start.add(Duration(minutes: duration));
      return DateFormat("HH:mm").format(end);
    } catch (e) {
      print("Error calculating end time: $e");
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<dynamic>> groupedShowtimes = {};
    for (var s in showtimes) {
      DateTime showDate =
          DateTime.parse(s['thoi_gian_chieu']); // KHÔNG toLocal()
      if (selectedDate != null &&
          showDate.year == selectedDate!.year &&
          showDate.month == selectedDate!.month &&
          showDate.day == selectedDate!.day) {
        String cinemaName = s['id_rap']['ten_rap'] ?? "Không rõ rạp";
        groupedShowtimes.putIfAbsent(cinemaName, () => []);
        groupedShowtimes[cinemaName]!.add(s);
      }
    }

    return ListView(
      padding: const EdgeInsets.all(10),
      children: groupedShowtimes.entries.map((entry) {
        final isExpanded = expandedCinemas[entry.key] ?? false;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => toggleCinema(entry.key),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: isExpanded
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: entry.value.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.5,
                      ),
                      itemBuilder: (context, index) {
                        final schedule = entry.value[index];
                        final fullStartTime = schedule["thoi_gian_chieu"];
                        final startDateTime =
                            DateTime.parse(fullStartTime); // KHÔNG toLocal()
                        final start = DateFormat("HH:mm").format(startDateTime);

                        final duration =
                            schedule["id_phim"]?["thoi_luong"] ?? 120;
                        final end = calculateEndTime(fullStartTime, duration);

                        return GestureDetector(
                          onTap: () async {
                            String? token = await StorageService.getToken();
                            if (token == null) {
                              bool? result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                              );
                              if (result == true) {
                                token = await StorageService.getToken();
                                if (token != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PickseatScreen(schedule: schedule),
                                    ),
                                  );
                                }
                              }
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PickseatScreen(schedule: schedule),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                              color: Colors.white,
                            ),
                            alignment: Alignment.center,
                            child: Text.rich(
                              TextSpan(
                                text: start,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                children: [
                                  const TextSpan(
                                    text: " ~ ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  TextSpan(
                                    text: end,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      })
                  : const SizedBox(),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }
}
