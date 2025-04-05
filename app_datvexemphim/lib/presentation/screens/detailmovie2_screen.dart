import 'package:app_datvexemphim/api/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:app_datvexemphim/presentation/screens/detailxemtatca_screen.dart';

class DetailMovieScreen2 extends StatefulWidget {
  final Map<String, dynamic> movie;

  const DetailMovieScreen2({super.key, required this.movie});

  @override
  _DetailMovieScreen2State createState() => _DetailMovieScreen2State();
}

class _DetailMovieScreen2State extends State<DetailMovieScreen2> {
  YoutubePlayerController? _youtubeController;
  bool _isExpanded = false;
  List<dynamic> _reviews = []; // Danh sách bình luận

  @override
  void initState() {
    super.initState();
    _initYouTubeController();
    _fetchReviews(); // Gọi hàm để lấy bình luận
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

  Future<void> _fetchReviews() async {
    try {
      final response =
          await ApiService.get('/reviews/movie/${widget.movie["_id"]}');
      if (response != null && response.statusCode == 200) {
        setState(() {
          _reviews = response.data; // Lưu bình luận vào danh sách
        });
      }
    } catch (e) {
      print("❌ Lỗi khi lấy bình luận: $e");
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

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Hình ảnh người bình luận
            CircleAvatar(
              backgroundImage: NetworkImage(review["id_nguoi_dung"]
                      ?["hinhAnh"] ??
                  "https://via.placeholder.com/150"),
              radius: 25,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review["id_nguoi_dung"]?["hoTen"] ?? "Người dùng",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(review["binh_luan"] ?? "Không có bình luận"),
                  const SizedBox(height: 5),
                  Text(
                    _formatDate(review["createdAt"]),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    return Scaffold(
      backgroundColor: Color(0xfff9f9f9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Chi tiết Phim",
          style: const TextStyle(
            color: Color(0xFF545454),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Color(0xffffffff),
              child: Padding(
                padding: const EdgeInsets.all(12),
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
                                    style:
                                        TextStyle(color: Color(0xFF545454))))),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            Card(
              color: Color(0xffffffff),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nội dung phim",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    HtmlWidget(
                      _isExpanded
                          ? movie["mo_ta"] ?? "<p>Không có mô tả</p>"
                          : (movie["mo_ta"]?.substring(0, 200) ??
                                  "<p>Không có mô tả</p>") +
                              "...",
                      textStyle: const TextStyle(
                          color: Color(0xFF545454), fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Text(_isExpanded ? "Thu gọn" : "Xem thêm"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),

            // Hiển thị bình luận
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text("Bình luận",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ..._reviews.map((review) =>
                _buildReviewCard(review)), // Hiển thị danh sách bình luận
          ],
        ),
      ),
    );
  }
}
