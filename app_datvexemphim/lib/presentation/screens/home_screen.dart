import 'package:app_datvexemphim/api/api_service.dart';
import 'package:app_datvexemphim/presentation/screens/detailmovie_screen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> nowShowingMovies = [];
  List<dynamic> comingSoonMovies = [];
  bool isLoading = true;
  final String imageBaseUrl = "https://rapchieuphim.com"; // Đường dẫn cố định

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
      backgroundColor: const Color(0xfff9f9f9),
      appBar: AppBar(
        elevation: 10,
        backgroundColor: const Color(0xFFB22222),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xffcc040a),
                Color(0xffb80407),
                Color(0xff940404),
                Color(0xff87040a)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            Image.asset(
              'assets/images/logo2.png', // Thay bằng đường dẫn logo của bạn
              height: 40,
            ),

            // Icon người dùng
            IconButton(
              icon: const Icon(Icons.account_circle,
                  size: 30, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), // Giúp nội dung cuộn mượt mà
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20), // Tránh bị khuất nội dung
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator()) // Hiển thị vòng xoay khi tải
                  : nowShowingMovies.isEmpty
                      ? const Center(
                          child: Text("Không có phim nào đang chiếu",
                              style: TextStyle(color: Colors.white)))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tiêu đề "Phim Đang Chiếu"
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: Text(
                                "Phim Đang Chiếu",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Carousel Phim Đang Chiếu
                            CarouselSlider(
                              options: CarouselOptions(
                                height: MediaQuery.of(context).size.width * 1.2,
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
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 20),
                              child: Text(
                                "Phim Sắp Chiếu",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // Carousel ngang Phim Sắp Chiếu
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: comingSoonMovies.map((movie) {
                                  String fullImageUrl = imageBaseUrl +
                                      (movie["url_poster"] ?? "");
                                  return Container(
                                    margin: const EdgeInsets.only(right: 10),
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
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
