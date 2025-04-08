import 'package:app_datvexemphim/data/services/storage_service.dart';
import 'package:app_datvexemphim/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_datvexemphim/api/api_service.dart';
import 'package:intl/intl.dart';
import 'package:app_datvexemphim/presentation/screens/pickseat_screen.dart';

class PickMovieAndTimeScreen extends StatefulWidget {
  final Map<String, dynamic> cinema;

  const PickMovieAndTimeScreen({super.key, required this.cinema});

  @override
  _PickMovieAndTimeScreenState createState() => _PickMovieAndTimeScreenState();
}

class _PickMovieAndTimeScreenState extends State<PickMovieAndTimeScreen> {
  List<dynamic> movieSchedules = [];
  bool isLoading = true;
  int selectedDateIndex = 0;

  List<DateTime> upcomingDates = List.generate(7, (index) {
    return DateTime.now().add(Duration(days: index));
  });

  @override
  void initState() {
    super.initState();
    fetchMovieSchedules();
  }

  Future<void> fetchMovieSchedules() async {
    setState(() => isLoading = true);
    try {
      final response =
          await ApiService.get("/book/all-lich-chieu/${widget.cinema['_id']}");
      if (response?.statusCode == 200 &&
          response?.data is Map<String, dynamic>) {
        setState(() => movieSchedules = response?.data['lich_chieu'] ?? []);
      } else {
        setState(() => movieSchedules = []);
      }
    } catch (e) {
      print("❌ Lỗi khi lấy lịch chiếu: $e");
      setState(() => movieSchedules = []);
    }
    setState(() => isLoading = false);
  }

  Map<String, dynamic> getGroupedMovies() {
    String selectedDate =
        DateFormat('yyyy-MM-dd').format(upcomingDates[selectedDateIndex]);

    Map<String, dynamic> groupedMovies = {};

    for (var movie in movieSchedules) {
      String? movieDate = movie["thoi_gian_chieu"]?.substring(0, 10);
      if (movieDate == selectedDate) {
        String movieId = movie["id_phim"]["_id"];
        if (!groupedMovies.containsKey(movieId)) {
          groupedMovies[movieId] = {
            "movie": movie["id_phim"],
            "schedules": [],
          };
        }
        groupedMovies[movieId]["schedules"].add(movie);
      }
    }

    return groupedMovies;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> groupedMovies = getGroupedMovies();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.cinema['ten_rap'] ?? "Rạp Chiếu Phim"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 14), // khoảng cách giữa AppBar và thanh ngày
          SizedBox(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: upcomingDates.length,
                itemBuilder: (context, index) {
                  DateTime date = upcomingDates[index];
                  bool isSelected = index == selectedDateIndex;
                  return GestureDetector(
                    onTap: () => setState(() => selectedDateIndex = index),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: 55,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.redAccent : Colors.white,
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
                              color: isSelected ? Colors.white : Colors.black54,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            DateFormat('dd').format(date),
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
                },
              ),
            ),
          ),
          const SizedBox(height: 14), // khoảng cách giữa thanh ngày và card
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : groupedMovies.isEmpty
                    ? Center(
                        child: Text(
                        "Không có lịch chiếu nào.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ))
                    : ListView(
                        padding: const EdgeInsets.all(10),
                        children: groupedMovies.entries.map((entry) {
                          var movieData = entry.value;
                          return MovieScheduleCard(
                            movie: movieData["movie"],
                            schedules: movieData["schedules"],
                          );
                        }).toList(),
                      ),
          ),
        ],
      ),
    );
  }
}

//Fix lỗi cho Sinh
class MovieScheduleCard extends StatelessWidget {
  final Map<String, dynamic> movie;
  final List<dynamic> schedules;

  const MovieScheduleCard({
    super.key,
    required this.movie,
    required this.schedules,
  });

  String calculateEndTime(String startTime, int duration) {
    try {
      final start = DateFormat("HH:mm").parse(startTime);
      final end = start.add(Duration(minutes: duration));
      return DateFormat("HH:mm").format(end);
    } catch (e) {
      return "";
    }
  }

  // Hàm lấy màu theo giới hạn độ tuổi
  Color _getAgeLimitColor(String? ageLimit) {
    switch (ageLimit) {
      case "K":
        return Colors.blue;
      case "T13":
        return Colors.yellow;
      case "T16":
        return Colors.orange;
      case "T18":
        return Colors.red;
      case "P":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    String movieTitle = movie["ten_phim"] ?? "Không có tên";
    String imageUrl = "https://rapchieuphim.com${movie["url_poster"] ?? ""}";
    String genre = movie["the_loai"] ?? "Đang cập nhật";
    String format = movie["dinh_dang"] ?? "2D";
    int duration = movie["thoi_luong"] ?? 120;
    String rating = movie["gioi_han_tuoi"] ?? "16+";

    // Lấy màu theo rating
    Color ratingColor = _getAgeLimitColor(rating);

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    height: 150,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        width: 100,
                        color: Colors.grey,
                        child:
                            const Icon(Icons.broken_image, color: Colors.white),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movieTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: ratingColor, // Áp dụng màu ở đây
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  rating,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "$genre | $format | $duration phút",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Giờ của PickMovie fix Sinh
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: schedules.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio:
                                  2.5, // Điều chỉnh childAspectRatio để tránh co giãn xuống dòng
                            ),
                            itemBuilder: (context, index) {
                              final schedule = schedules[index];
                              final start =
                                  schedule["thoi_gian_chieu"].substring(11, 16);
                              final end = schedule["thoi_gian_ket_thuc"] != null
                                  ? schedule["thoi_gian_ket_thuc"]
                                      .substring(11, 16)
                                  : calculateEndTime(start, duration);

                              return GestureDetector(
                                onTap: () async {
                                  String? token =
                                      await StorageService.getToken();
                                  if (token == null) {
                                    bool? result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen()),
                                    );
                                    if (result == true) {
                                      token = await StorageService.getToken();
                                      if (token != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PickseatScreen(
                                                    schedule: schedule),
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
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
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
