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

  // Gộp các suất chiếu cùng phim vào 1 nhóm
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
      ),
      body: Column(
        children: [
          // Thanh chọn ngày
          SizedBox(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10), // Thêm khoảng cách hai bên
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
                      margin: const EdgeInsets.symmetric(
                          horizontal: 6), // Khoảng cách giữa các ô ngày
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
                        padding: EdgeInsets.all(10),
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

class MovieScheduleCard extends StatelessWidget {
  final Map<String, dynamic> movie;
  final List<dynamic> schedules;

  const MovieScheduleCard(
      {super.key, required this.movie, required this.schedules});

  @override
  Widget build(BuildContext context) {
    String movieTitle = movie["ten_phim"] ?? "Không có tên";
    String imageUrl = "https://rapchieuphim.com" + (movie["url_poster"] ?? "");

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                height: 120,
                width: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    width: 80,
                    color: Colors.grey,
                    child: Icon(Icons.broken_image, color: Colors.white),
                  );
                },
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movieTitle,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // ✅ 3 cột cân đối
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.5, // ✅ Giữ kích thước đẹp
                    ),
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      var schedule = schedules[index];
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 255, 137, 137),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        // onPressed: () {
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) =>
                        //           PickseatScreen(schedule: schedule),
                        //     ),
                        //   );
                        // },
                        onPressed: () async {
                          String? token = await StorageService.getToken();
                          if (token == null) {
                            // Nếu chưa đăng nhập -> Chuyển sang LoginScreen
                            bool? result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()),
                            );

                            // Nếu đăng nhập thành công -> Chuyển sang PickseatScreen
                            if (result == true) {
                              token = await StorageService
                                  .getToken(); // Kiểm tra lại token
                              if (token != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PickseatScreen(schedule: schedule)),
                                );
                              }
                            }
                          } else {
                            // Nếu đã đăng nhập -> Chuyển sang PickseatScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PickseatScreen(schedule: schedule)),
                            );
                          }
                        },
                        child: Text(
                          schedule['thoi_gian_chieu'].substring(11, 16),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
