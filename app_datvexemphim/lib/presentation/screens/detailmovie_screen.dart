import 'package:app_datvexemphim/presentation/screens/pickcinemaandtime_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DetailMovieScreen extends StatefulWidget {
  final Map<String, dynamic> movie;
  const DetailMovieScreen({Key? key, required this.movie}) : super(key: key);

  @override
  _DetailMovieScreenState createState() => _DetailMovieScreenState();
}

class _DetailMovieScreenState extends State<DetailMovieScreen> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _initYouTubeController();
  }

  void _initYouTubeController() {
    final trailerUrl = widget.movie["url_trailer"];
    if (trailerUrl != null) {
      final videoId = YoutubePlayer.convertUrlToId(trailerUrl);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
        );
      }
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "Không rõ";
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(dateString));
    } catch (_) {
      return "Không rõ";
    }
  }

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

  Widget _buildMovieInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 17),
        ),
        const SizedBox(width: 8),
        Text("$label: ",
            style: const TextStyle(
                color: Color(0xFF545454),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        Text(value,
            style: const TextStyle(color: Color(0xFF545454), fontSize: 15)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          movie['ten_phim'] ?? "Chọn Giờ Chiếu",
          style: const TextStyle(
              color: Color(0xFF545454), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _youtubeController != null
                ? YoutubePlayer(controller: _youtubeController!)
                : Container(
                    height: 200,
                    color: Colors.black26,
                    child: const Center(
                        child: Text("Không có trailer",
                            style: TextStyle(color: Color(0xFF545454))))),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    movie["ten_phim"] ?? "Không có tên",
                    style: const TextStyle(
                        color: Color(0xFF545454),
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getAgeLimitColor(movie["gioi_han_tuoi"]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    movie["gioi_han_tuoi"] ?? "P",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildMovieInfoRow(FontAwesome.calendar_solid, "Ngày chiếu",
                _formatDate(movie["ngay_cong_chieu"])),
            const SizedBox(height: 10),
            _buildMovieInfoRow(FontAwesome.clock_solid, "Thời lượng",
                "${movie["thoi_luong"] ?? "Không rõ"} phút"),
            const SizedBox(height: 20),
            HtmlWidget(
              movie["mo_ta"] ?? "<p>Không có mô tả</p>",
              textStyle:
                  const TextStyle(color: Color(0xFF545454), fontSize: 16),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PickCinemaAndTimeScreen(movie: movie),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEE0033),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 6,
                shadowColor: Colors.black26,
              ),
              child: const Text("Đặt Vé",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}
