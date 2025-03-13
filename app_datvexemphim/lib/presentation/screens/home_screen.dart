import 'package:app_datvexemphim/api/api_service.dart';
import 'package:app_datvexemphim/presentation/screens/detailmovie_screen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> nowShowingMovies = [];
  List<dynamic> comingSoonMovies = [];
  bool isLoading = true;
  final String imageBaseUrl = "https://rapchieuphim.com"; // Đường dẫn cố định

  String selectedLocation = "TP.HCM"; // Vị trí mặc định

  @override
  void initState() {
    super.initState();
    fetchNowShowingMovies();
    fetchComingSoonMovies();
  }

  // Fetch phim đang chiếu
  Future<void> fetchNowShowingMovies() async {
    Response? response = await ApiService.get("/phims/dangchieu");
    if (response != null && response.statusCode == 200) {
      setState(() {
        nowShowingMovies = response.data;
      });
    }
    setState(() => isLoading = false);
  }

  // Fetch phim sắp chiếu
  Future<void> fetchComingSoonMovies() async {
    Response? response = await ApiService.get("/phims/sapchieu");
    if (response != null && response.statusCode == 200) {
      setState(() {
        comingSoonMovies = response.data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        title: Text(
          "ATSH CGV.",
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 0, 0),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              _showLocationPicker(context, (value) {
                setState(() {
                  selectedLocation = value;
                });
              });
            },
            child: Row(
              children: [
                Text(
                  selectedLocation ?? "Chọn vị trí",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.black),
                SizedBox(width: 10),
              ],
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(), // Giúp nội dung cuộn mượt mà
        child: Padding(
          padding: EdgeInsets.only(bottom: 20), // Tránh bị khuất nội dung
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isLoading
                  ? Center(
                      child:
                          CircularProgressIndicator()) // Hiển thị vòng xoay khi tải
                  : nowShowingMovies.isEmpty
                      ? Center(
                          child: Text("Không có phim nào đang chiếu",
                              style: TextStyle(color: Colors.black)))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tiêu đề "Phim Đang Chiếu"
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: Text(
                                "Phim Đang Chiếu",
                                style: TextStyle(
                                  color: Color(0xFF545454),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                            // Carousel Phim Đang Chiếu
                            CarouselSlider(
                              options: CarouselOptions(
                                height: MediaQuery.of(context).size.width * 1.3,
                                autoPlay: true,
                                enlargeCenterPage: true,
                              ),
                              items: nowShowingMovies.map((movie) {
                                String fullImageUrl =
                                    imageBaseUrl + (movie["url_poster"] ?? "");
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailMovieScreen(movie: movie),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: AspectRatio(
                                      aspectRatio: 2 / 3,
                                      child: Image.network(
                                        fullImageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.network(
                                            "https://via.placeholder.com/300",
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            // Tiêu đề "Phim Sắp Chiếu"
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 20),
                              child: Text(
                                "Phim Sắp Chiếu",
                                style: TextStyle(
                                  color: Color(0xFF545454),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ),

                            // Carousel ngang Phim Sắp Chiếu
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: comingSoonMovies.map((movie) {
                                  String fullImageUrl = imageBaseUrl +
                                      (movie["url_poster"] ?? "");
                                  String movieTitle =
                                      movie["ten_phim"] ?? "Không có tên";

                                  return Container(
                                    margin: EdgeInsets.only(right: 10),
                                    width: 150,
                                    child: Column(
                                      children: [
                                        // Hình ảnh phim
                                        ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: AspectRatio(
                                              aspectRatio: 2 / 3,
                                              child: Image.network(
                                                fullImageUrl,
                                                height: 220,
                                                width: 150,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Image.network(
                                                    "https://via.placeholder.com/150",
                                                    height: 220,
                                                    width: 150,
                                                    fit: BoxFit.cover,
                                                  );
                                                },
                                              ),
                                            )),
                                        SizedBox(height: 8),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: 100),
                          ],
                        ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm mở dialog chọn vị trí
  void _showLocationPicker(BuildContext context, Function(String) onSelected) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Chọn vị trí"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ["Hà Nội", "TP.HCM", "Đà Nẵng"].map((city) {
              return ListTile(
                title: Text(city),
                onTap: () {
                  onSelected(city);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
