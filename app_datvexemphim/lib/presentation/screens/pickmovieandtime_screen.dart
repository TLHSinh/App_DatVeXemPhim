import 'package:app_datvexemphim/presentation/screens/pickseat_screen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:app_datvexemphim/api/api_service.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/date_symbol_data_local.dart';

class PickMovieAndTimeScreen extends StatefulWidget {
  final Map<String, dynamic> cinema;

  const PickMovieAndTimeScreen({super.key, required this.cinema});

  @override
  _PickMovieAndTimeScreenState createState() => _PickMovieAndTimeScreenState();
}

class _PickMovieAndTimeScreenState extends State<PickMovieAndTimeScreen> {
  List<dynamic> movieSchedules = [];
  bool isLoading = true;

  // Danh sách 7 ngày từ hôm nay
  List<DateTime> upcomingDates = List.generate(7, (index) {
    return DateTime.now().add(Duration(days: index));
  });

  int selectedDateIndex = 0; // Mặc định là ngày đầu tiên

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
        var data = response?.data as Map<String, dynamic>;
        setState(() => movieSchedules = data['lich_chieu'] ?? []);
      } else {
        setState(() => movieSchedules = []);
      }
    } catch (e) {
      print("❌ Lỗi khi lấy lịch chiếu: $e");
      setState(() => movieSchedules = []);
    }
    setState(() => isLoading = false);
  }

  // Lọc danh sách phim theo ngày đã chọn
  List<dynamic> getFilteredMovies() {
    String selectedDate =
        DateFormat('yyyy-MM-dd').format(upcomingDates[selectedDateIndex]);

    return movieSchedules.where((movie) {
      String movieDate =
          movie["thoi_gian_chieu"].substring(0, 10); // Lấy yyyy-MM-dd
      return movieDate == selectedDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredMovies = getFilteredMovies();

    return Scaffold(
      backgroundColor: const Color(0xff1B1B1B),
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 🔥 Carousel chọn ngày
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: CarouselSlider(
              options: CarouselOptions(
                height: 70,
                viewportFraction: 0.22,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    selectedDateIndex = index;
                  });
                },
              ),
              items: List.generate(upcomingDates.length, (index) {
                DateTime date = upcomingDates[index];
                bool isSelected = index == selectedDateIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDateIndex = index;
                    });
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.redAccent : Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E', 'vi').format(date), // Thứ (T2, T3...)
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM').format(date), // Ngày/tháng
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredMovies.isEmpty
                    ? const Center(
                        child: Text(
                          "Không có lịch chiếu nào.",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredMovies.length,
                        itemBuilder: (context, index) {
                          var movie = filteredMovies[index];
                          return MovieScheduleCard(movie: movie);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// 🎥 Widget hiển thị phim
class MovieScheduleCard extends StatelessWidget {
  final Map<String, dynamic> movie;

  const MovieScheduleCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    String movieTitle = movie["id_phim"]?["ten_phim"] ?? "Không có tên";
    String imageBaseUrl = "https://rapchieuphim.com";
    String fullImageUrl = imageBaseUrl + (movie["id_phim"]?["url_poster"] ?? "");
    String scheduleTime = movie["thoi_gian_chieu"] ?? "Không có giờ";

    return Card(
      color: Colors.white10,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  fullImageUrl,
                  height: 100,
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      "https://via.placeholder.com/300",
                      height: 50,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
                              Text(
                  movieTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PickseatScreen(schedule: movie),
                      ),
                    );
                  },
                  child: Text(
                    scheduleTime.length > 16
                        ? scheduleTime.substring(11, 16)
                        : scheduleTime,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
