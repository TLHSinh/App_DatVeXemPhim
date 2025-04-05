import 'package:app_datvexemphim/presentation/screens/pickcinemaandtime_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app_datvexemphim/api/api_service.dart';
import 'package:app_datvexemphim/presentation/screens/detailmovie_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailXemTatCaHome extends StatefulWidget {
  @override
  _DetailXemTatCaHomeState createState() => _DetailXemTatCaHomeState();
}

class _DetailXemTatCaHomeState extends State<DetailXemTatCaHome> {
  List<dynamic> nowShowingMovies = [];
  bool isLoading = true;
  final String imageBaseUrl = "https://rapchieuphim.com";

  @override
  void initState() {
    super.initState();
    fetchNowShowingMovies();
  }

  Future<void> fetchNowShowingMovies() async {
    try {
      final response = await ApiService.get("/movie/phims/dangchieu");
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Phim đang chiếu",
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
              ? const Center(child: Text("Không có phim nào đang chiếu"))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: nowShowingMovies.length,
                  itemBuilder: (context, index) {
                    final movie = nowShowingMovies[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MovieCard(movie: movie),
                    );
                  },
                ),
    );
  }
}

class MovieCard extends StatefulWidget {
  final Map movie;
  final String imageBaseUrl = "https://rapchieuphim.com";

  const MovieCard({super.key, required this.movie});

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool isFavorite = false;

  String _formatDate(String dateStr) {
    try {
      DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return "Không rõ";
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final movieId = widget.movie['id_phim']?.toString() ?? '';
    setState(() {
      isFavorite = prefs.getBool('favorite_$movieId') ?? false;
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final movieId = widget.movie['id_phim']?.toString() ?? '';
    setState(() {
      isFavorite = !isFavorite;
      prefs.setBool('favorite_$movieId', isFavorite);
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.movie["url_poster"] != null
        ? widget.imageBaseUrl + widget.movie["url_poster"]
        : "https://via.placeholder.com/100x140";

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 6,
      shadowColor: Colors.grey.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 100,
                height: 150,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Container(
                  width: 100,
                  height: 140,
                  color: Colors.grey[300],
                  child: const Icon(Icons.movie, size: 40, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              widget.movie['danh_gia']?.toString() ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _toggleFavorite,
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.movie['ten_phim'] ?? 'Không có tiêu đề',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: Colors.redAccent),
                      const SizedBox(width: 4),
                      Text(
                        "${widget.movie['thoi_luong'] ?? 'N/A'} phút",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month,
                          size: 16, color: Colors.blueAccent),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(widget.movie['ngay_cong_chieu'] ?? ""),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailMovieScreen(
                                    movie: Map<String, dynamic>.from(
                                        widget.movie)),
                              ),
                            );
                          },
                          icon: const Icon(Icons.info_outline,
                              size: 16, color: Colors.red),
                          label: const Text("Chi tiết",
                              style: TextStyle(color: Colors.black)),
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PickCinemaAndTimeScreen(
                                    movie: Map<String, dynamic>.from(
                                        widget.movie)),
                              ),
                            );
                          },
                          icon: const Icon(Icons.confirmation_num_outlined,
                              size: 14),
                          label: const Text("Mua vé"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
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
