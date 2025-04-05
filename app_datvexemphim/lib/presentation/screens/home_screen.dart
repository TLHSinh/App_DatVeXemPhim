import 'dart:math';
import 'package:app_datvexemphim/api/api_service.dart';
import 'package:app_datvexemphim/presentation/screens/detailmovie2_screen.dart';
import 'package:app_datvexemphim/presentation/screens/detailmovie_screen.dart';
import 'package:app_datvexemphim/presentation/screens/detailxemtatcaSC_screen.dart';
import 'package:app_datvexemphim/presentation/screens/detailxemtatca_screen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> nowShowingMovies = [];
  List<dynamic> comingSoonMovies = [];
  List<dynamic> adsList = [];
  List<dynamic> latestMoviesAds =
      []; // Danh sách phim mới nhất từ API quảng cáo
  bool isLoading = true;
  bool showPopup = false;
  Map<String, dynamic>? randomMovie;
  final String imageBaseUrl = "https://rapchieuphim.com";

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    try {
      final responses = await Future.wait([
        ApiService.get("/movie/phims/dangchieu"),
        ApiService.get("/movie/phims/sapchieu"),
        ApiService.get("/admin/ads"),
        ApiService.get("/movie/phims/dangchieuforads"), // API lấy phim mới nhất
      ]);

      setState(() {
        nowShowingMovies =
            responses[0]?.statusCode == 200 ? responses[0]?.data : [];
        comingSoonMovies =
            responses[1]?.statusCode == 200 ? responses[1]?.data : [];
        adsList = responses[2]?.statusCode == 200 ? responses[2]?.data : [];
        latestMoviesAds =
            responses[3]?.statusCode == 200 ? responses[3]?.data : [];
        isLoading = false;

        // Chọn ngẫu nhiên một phim từ danh sách quảng cáo
        if (latestMoviesAds.isNotEmpty) {
          final randomIndex = Random().nextInt(latestMoviesAds.length);
          randomMovie = latestMoviesAds[randomIndex];
          showPopup = true;
        }
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
        automaticallyImplyLeading: false,
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
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (adsList.isNotEmpty) _buildAdsSlider(),
                  _buildSectionTitle("Phim Nổi Bật"),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : nowShowingMovies.isEmpty
                          ? _buildEmptyMessage("Không có phim nào đang chiếu")
                          : _buildMovieSlider(nowShowingMovies),
                  const SizedBox(height: 24),
                  comingSoonMovies.isEmpty
                      ? _buildEmptyMessage("Không có phim đang chiếu")
                      : _buildNowShowingMovies(),
                  const SizedBox(height: 14),
                  comingSoonMovies.isEmpty
                      ? _buildEmptyMessage("Không có phim sắp chiếu")
                      : _buildComingSoonMovies(),
                  const SizedBox(height: 34),
                ],
              ),
            ),
          ),
          if (showPopup) _buildPopup(),
        ],
      ),
    );
  }

  Widget _buildPopup() {
    return AnimatedOpacity(
      opacity: showPopup ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Center(
        child: GestureDetector(
          onTap: () => setState(() => showPopup = false),
          child: Container(
            color: Colors.black.withOpacity(0.5),
            width: double.infinity,
            height: double.infinity,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (randomMovie != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailMovieScreen(movie: randomMovie!),
                          ),
                        );
                        setState(() => showPopup = false);
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: randomMovie?["url_poster"] != null
                            ? imageBaseUrl + randomMovie!["url_poster"]
                            : "https://via.placeholder.com/300",
                        width: 300,
                        height: 450,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => showPopup = false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
                Image.network("https://via.placeholder.com/600x300"),
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
                builder: (context) => DetailMovieScreen(movie: movie),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: movie["url_poster"] != null
                  ? imageBaseUrl + movie["url_poster"]
                  : "https://via.placeholder.com/300",
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) =>
                  Image.network("https://via.placeholder.com/300"),
            ),
          ),
        );
      }).toList(),
    );
  }

  //Phim ĐANG Chiếu
  Widget _buildNowShowingMovies() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (nowShowingMovies.isEmpty) {
      return _buildEmptyMessage("Không có phim nào đang chiếu");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Phim hay Đang chiếu",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailXemTatCaHome(),
                    ),
                  );
                },
                child: const Text(
                  "Xem tất cả >",
                  style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount:
                nowShowingMovies.length > 8 ? 8 : nowShowingMovies.length,
            itemBuilder: (context, index) {
              final movie = nowShowingMovies[index];
              final imageUrl = movie["url_poster"] != null
                  ? imageBaseUrl + movie["url_poster"]
                  : "https://via.placeholder.com/150";

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailMovieScreen(movie: movie),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 130,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          height: 180,
                          width: 130,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              Image.network("https://via.placeholder.com/150"),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        movie["ten_phim"] ?? "Không có tiêu đề",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        movie["genre"] ?? "Hài - Tình cảm",
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  //Phim SẮP Chiếu
  Widget _buildComingSoonMovies() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (comingSoonMovies.isEmpty) {
      return _buildEmptyMessage("Không có phim nào Sắp chiếu");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Phim hay Sắp chiếu",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailXemTatCaSapChieu(),
                    ),
                  );
                },
                child: const Text(
                  "Xem tất cả >",
                  style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount:
                comingSoonMovies.length > 8 ? 8 : comingSoonMovies.length,
            itemBuilder: (context, index) {
              final movie = comingSoonMovies[index];
              final imageUrl = movie["url_poster"] != null
                  ? imageBaseUrl + movie["url_poster"]
                  : "https://via.placeholder.com/150";

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailMovieScreen2(movie: movie),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 130,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          height: 180,
                          width: 130,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              Image.network("https://via.placeholder.com/150"),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        movie["ten_phim"] ?? "Không có tiêu đề",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
