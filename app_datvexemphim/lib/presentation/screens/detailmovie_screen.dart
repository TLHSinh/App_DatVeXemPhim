import 'package:app_datvexemphim/presentation/screens/pickcinemaandtime_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DetailMovieScreen extends StatefulWidget {
  final Map<String, dynamic> movie;

  const DetailMovieScreen({Key? key, required this.movie}) : super(key: key);

  @override
  _DetailMovieScreenState createState() => _DetailMovieScreenState();
}

class _DetailMovieScreenState extends State<DetailMovieScreen> {
  YoutubePlayerController? _youtubeController;
  // VideoPlayerController? _videoController;
  // bool isYouTube = false;

  @override
  void initState() {
    super.initState();
    String? trailerUrl = widget.movie["url_trailer"];

    if (trailerUrl != null) {
      if (trailerUrl.contains("youtube.com") ||
          trailerUrl.contains("youtube.com/embed/")) {
        trailerUrl = trailerUrl
            .replaceAll("//", "https://")
            .replaceAll("embed/", "watch?v=");
        String? videoId = YoutubePlayer.convertUrlToId(trailerUrl);
        if (videoId != null) {
          _youtubeController = YoutubePlayerController(
            initialVideoId: videoId,
            flags: YoutubePlayerFlags(autoPlay: false, mute: false),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1B1B1B),
      appBar: AppBar(
        title: Text(
          widget.movie["ten_phim"] ?? "Chi Tiết Phim",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(height: 16),
            if (_youtubeController != null)
              YoutubePlayer(controller: _youtubeController!)
            else
              Container(
                height: 200,
                color: Colors.black26,
                child: Center(
                    child: Text("Không có trailer",
                        style: TextStyle(color: Colors.white))),
              ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  widget.movie["ten_phim"] ?? "Không có tên",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getAgeLimitColor(
                        widget.movie["gioi_han_tuoi"] ?? "P"), // Chọn màu nền
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.movie["gioi_han_tuoi"] ??
                        "P", // Mặc định là "P" nếu không có
                    style: TextStyle(
                      color: Colors.white, // Chữ trắng
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(FontAwesome.calendar_solid,
                      color: Colors.black, size: 17),
                ),
                SizedBox(width: 8),
                Text("Ngày chiếu: ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text(
                  "${widget.movie["ngay_cong_chieu"] ?? "Không rõ"}",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(FontAwesome.clock, color: Colors.black, size: 17),
                ),
                SizedBox(width: 8),
                Text("Thời lượng: ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text(
                  "${widget.movie["thoi_luong"] ?? "Không rõ"} phút",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
            SizedBox(height: 20),
            HtmlWidget(
              widget.movie["mo_ta"] ?? "<p>Không có mô tả</p>",
              textStyle: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              // Chuyển đến trang chọn rạp & thời gian
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PickCinemaAndTimeScreen(movie: widget.movie),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "Đặt Vé",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Color _getAgeLimitColor(String ageLimit) {
    switch (ageLimit) {
      case "K":
        return Colors.blue; // K - Xanh dương
      case "T13":
        return Colors.yellow; // T13 - Vàng
      case "T16":
        return Colors.orange; // T16 - Cam
      case "T18":
        return Colors.red; // T18 - Đỏ
      case "P":
        return Colors.green; // P - Xanh lá
      default:
        return Colors.grey; // Mặc định màu xám nếu không xác định
    }
  }
}