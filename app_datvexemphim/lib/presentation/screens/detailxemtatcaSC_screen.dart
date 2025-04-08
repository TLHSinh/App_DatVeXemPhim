import 'package:app_datvexemphim/presentation/screens/detailmovie2_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:app_datvexemphim/api/api_service.dart';

class DetailXemTatCaSapChieu extends StatefulWidget {
  @override
  _DetailXemTatCaSapChieuState createState() => _DetailXemTatCaSapChieuState();
}

class _DetailXemTatCaSapChieuState extends State<DetailXemTatCaSapChieu> {
  List<dynamic> allMovies = [];
  bool isLoading = true;
  final String imageBaseUrl = "https://rapchieuphim.com";

  @override
  void initState() {
    super.initState();
    fetchComingSoonMovies();
  }

  Future<void> fetchComingSoonMovies() async {
    try {
      final response = await ApiService.get("/movie/phims/sapchieu");
      if (response?.statusCode == 200) {
        setState(() {
          allMovies = response?.data ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Lỗi khi tải phim sắp chiếu: $e");
      setState(() => isLoading = false);
    }
  }

  Map<String, List<dynamic>> groupMoviesByMonth(List<dynamic> movies) {
    final Map<String, List<dynamic>> grouped = {};
    for (var movie in movies) {
      final releaseDate = DateTime.tryParse(movie["ngay_cong_chieu"] ?? "");
      if (releaseDate != null) {
        final monthKey = DateFormat("MMMM yyyy", "vi").format(releaseDate);
        grouped.putIfAbsent(monthKey, () => []).add(movie);
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedMovies = groupMoviesByMonth(allMovies);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Phim Sắp Chiếu",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : groupedMovies.isEmpty
              ? const Center(child: Text("Không có phim nào sắp chiếu"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10), // Thêm lề trái 10
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: groupedMovies.entries.map((entry) {
                        final month = entry.key;
                        final movies = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tháng ${DateFormat("MM/yyyy").format(DateFormat("MMMM yyyy", "vi").parse(month))}",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 260,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: movies.length,
                                itemBuilder: (context, index) {
                                  final movie = movies[index];
                                  final imageUrl = movie["url_poster"] != null
                                      ? imageBaseUrl + movie["url_poster"]
                                      : "https://via.placeholder.com/150";

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DetailMovieScreen2(movie: movie),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 140,
                                      margin: const EdgeInsets.only(right: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AspectRatio(
                                            aspectRatio: 0.66,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: CachedNetworkImage(
                                                imageUrl: imageUrl,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    const Center(
                                                        child:
                                                            CircularProgressIndicator()),
                                                errorWidget: (context, url,
                                                        error) =>
                                                    Image.network(
                                                        "https://via.placeholder.com/300"),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            movie["ten_phim"] ?? "Tên phim",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
    );
  }
}
