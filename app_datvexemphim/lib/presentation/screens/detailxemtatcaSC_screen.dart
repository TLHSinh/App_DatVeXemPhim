import 'package:app_datvexemphim/presentation/screens/detailmovie2_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app_datvexemphim/api/api_service.dart';

class DetailXemTatCaSapChieu extends StatefulWidget {
  @override
  _DetailXemTatCaSapChieuState createState() => _DetailXemTatCaSapChieuState();
}

class _DetailXemTatCaSapChieuState extends State<DetailXemTatCaSapChieu> {
  List<dynamic> nowShowingMovies = [];
  bool isLoading = true;
  final String imageBaseUrl = "https://rapchieuphim.com";

  @override
  void initState() {
    super.initState();
    fetchcomingSoonMovies();
  }

  Future<void> fetchcomingSoonMovies() async {
    try {
      final response = await ApiService.get("/movie/phims/sapchieu");
      if (response?.statusCode == 200) {
        setState(() {
          nowShowingMovies = response?.data ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Lỗi khi tải phim đang chiếu: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Phim Sắp chiếu",
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
          : nowShowingMovies.isEmpty
              ? const Center(child: Text("Không có phim nào sắp chiếu"))
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: nowShowingMovies.length,
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
                            builder: (context) =>
                                DetailMovieScreen2(movie: movie),
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
                  },
                ),
    );
  }
}
