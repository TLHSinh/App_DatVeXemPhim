import 'package:app_datvexemphim/api/api_service.dart';
import 'package:app_datvexemphim/presentation/screens/detailmovie_screen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> nowShowingMovies = [];
  List<dynamic> comingSoonMovies = [];
  List<dynamic> adsList = [];
  bool isLoading = true;
  final String imageBaseUrl = "https://rapchieuphim.com";

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    try {
      final responses = await Future.wait([
        ApiService.get("/phims/dangchieu"),
        ApiService.get("/phims/sapchieu"),
        ApiService.get("/admin/ads"),
      ]);

      setState(() {
        nowShowingMovies =
            responses[0]?.statusCode == 200 ? responses[0]?.data : [];
        comingSoonMovies =
            responses[1]?.statusCode == 200 ? responses[1]?.data : [];
        adsList = responses[2]?.statusCode == 200 ? responses[2]?.data : [];
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Lỗi khi tải dữ liệu: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xfff9f9f9),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/images/logo.png', height: 50),
            IconButton(
              icon: const Icon(Icons.search, size: 30, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (adsList.isNotEmpty) _buildAdsSlider(),
              _buildSectionTitle("Phim Đang Chiếu"),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : nowShowingMovies.isEmpty
                      ? _buildEmptyMessage("Không có phim nào đang chiếu")
                      : _buildMovieSlider(nowShowingMovies),
              _buildSectionTitle("Phim Sắp Chiếu"),
              comingSoonMovies.isEmpty
                  ? _buildEmptyMessage("Không có phim sắp chiếu")
                  : _buildComingSoonMovies(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdsSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
      items: adsList.map((ad) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: ad["url_hinh"] ?? "https://via.placeholder.com/600x300",
            fit: BoxFit.cover,
            width: double.infinity,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => Image.network(
              "https://via.placeholder.com/600x300",
              fit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyMessage(String message) {
    return Center(
      child: Text(message, style: const TextStyle(color: Colors.black)),
    );
  }

  Widget _buildMovieSlider(List<dynamic> movies) {
    return CarouselSlider(
      options: CarouselOptions(
        height: MediaQuery.of(context).size.width * 1.1,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.7,
      ),
      items: movies.map((movie) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailMovieScreen(movie: movie)));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: movie["url_poster"] != null
                  ? imageBaseUrl + movie["url_poster"]
                  : "https://via.placeholder.com/300",
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => Image.network(
                "https://via.placeholder.com/300",
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildComingSoonMovies() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: comingSoonMovies.map((movie) {
          return Container(
            margin: const EdgeInsets.only(right: 10),
            width: 150,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: movie["url_poster"] != null
                        ? imageBaseUrl + movie["url_poster"]
                        : "https://via.placeholder.com/150",
                    height: 220,
                    width: 150,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Image.network(
                      "https://via.placeholder.com/150",
                      height: 220,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
