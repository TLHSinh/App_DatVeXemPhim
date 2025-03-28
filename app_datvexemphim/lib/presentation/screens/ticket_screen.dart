import 'package:app_datvexemphim/data/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:app_datvexemphim/api/api_service.dart';
import 'package:intl/intl.dart';
import 'package:app_datvexemphim/presentation/screens/detailticketuser_screen.dart';
import 'package:app_datvexemphim/presentation/widgets/final_view.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({Key? key}) : super(key: key);

  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  List<dynamic> tickets = [];
  bool isLoading = true;
  String? userId;
  final String imageBaseUrl = "https://rapchieuphim.com";

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    userId = await StorageService.getUserId();
    if (userId != null) {
      try {
        final response = await ApiService.get("/ticket/listticket/$userId");
        if (response?.statusCode == 200) {
          setState(() {
            tickets = response?.data;
            isLoading = false;
          });
        }
      } catch (e) {
        print("❌ Lỗi khi lấy danh sách vé: $e");
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return "Chưa xác định";
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      String formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
      String formattedTime = DateFormat('HH:mm').format(dateTime);
      return "$formattedDate · $formattedTime - ${formattedTime != "00:00" ? _calculateEndTime(formattedTime, 120) : "00:00"}";
    } catch (e) {
      return "Chưa xác định";
    }
  }

  String _calculateEndTime(String startTime, int durationMinutes) {
    try {
      List<String> parts = startTime.split(':');
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);

      int totalMinutes = hours * 60 + minutes + durationMinutes;
      int endHours = (totalMinutes ~/ 60) % 24;
      int endMinutes = totalMinutes % 60;

      return "${endHours.toString().padLeft(2, '0')}:${endMinutes.toString().padLeft(2, '0')}";
    } catch (e) {
      return startTime;
    }
  }

  // Hàm xử lý khi người dùng nhấp vào vé
  void _navigateToTicketDetail(dynamic ticket) {
    // Điều hướng đến trang chi tiết vé
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsTicketScreen(
          ticketData: ticket,
        ),
      ),
    ).then((_) {
      // Khi quay lại màn hình danh sách vé, cập nhật lại danh sách
      _fetchTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Danh Sách Vé",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchTickets,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : tickets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Không có vé nào đã đặt."),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _fetchTickets,
                          child: const Text("Tải lại"),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      var ticket = tickets[index];
                      var movieData = ticket["id_lich_chieu"]?["id_phim"];
                      var showtime =
                          ticket["id_lich_chieu"]?["thoi_gian_chieu"];

                      return InkWell(
                        onTap: () {
                          // Điều hướng đến trang chi tiết vé
                          _navigateToTicketDetail(ticket);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Poster phim
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    movieData?["url_poster"] != null
                                        ? imageBaseUrl +
                                            movieData["url_poster"].toString()
                                        : "https://via.placeholder.com/300",
                                    width: 50,
                                    height: 75,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 50,
                                        height: 75,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.movie,
                                            color: Colors.grey),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Thông tin phim
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movieData?["ten_phim"]?.toUpperCase() ??
                                            "PHIM KHÔNG XÁC ĐỊNH",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDateTime(showtime),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Hiển thị trạng thái vé
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: _getStatusBackgroundColor(
                                                  ticket["trang_thai"]),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              _getStatusText(
                                                  ticket["trang_thai"]),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: _getStatusColor(
                                                    ticket["trang_thai"]),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            "Nhắc nhở trước 30 phút",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const Spacer(),
                                          Switch(
                                            value: false,
                                            onChanged: (value) {
                                              // Xử lý bật/tắt thông báo
                                            },
                                            activeColor: Colors.red,
                                            activeTrackColor:
                                                Colors.red.withOpacity(0.5),
                                            inactiveThumbColor:
                                                Colors.grey[400],
                                            inactiveTrackColor:
                                                Colors.grey[300],
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Icon mũi tên
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey[400],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case "da_thanh_toan":
        return "Đã thanh toán";
      case "da_su_dung":
        return "Đã sử dụng";
      case "da_huy":
        return "Đã hủy";
      default:
        return "Chưa xác định";
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case "da_thanh_toan":
        return Colors.green;
      case "da_su_dung":
        return Colors.blue;
      case "da_huy":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusBackgroundColor(String? status) {
    switch (status) {
      case "da_thanh_toan":
        return Colors.green.withOpacity(0.2);
      case "da_su_dung":
        return Colors.blue.withOpacity(0.2);
      case "da_huy":
        return Colors.red.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }
}
