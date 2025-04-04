import 'package:app_datvexemphim/data/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:app_datvexemphim/api/api_service.dart';
import 'package:intl/intl.dart';
import 'package:app_datvexemphim/presentation/screens/detailticketuser_screen.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

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

  void _navigateToTicketDetail(dynamic ticket) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsTicketScreen(
          ticketData: ticket,
        ),
      ),
    ).then((_) {
      _fetchTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text(
          "Danh Sách Vé",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            bottom: 70), // Space for bottom navigation bar
        child: RefreshIndicator(
          color: Colors.red,
          onRefresh: _fetchTickets,
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ))
              : tickets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_movies_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Không có vé nào đã đặt",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Hãy đặt vé xem phim ngay!",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _fetchTickets,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: const Text("Tải lại"),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: tickets.length,
                      itemBuilder: (context, index) {
                        var ticket = tickets[index];
                        var movieData = ticket["id_lich_chieu"]?["id_phim"];
                        var showtime =
                            ticket["id_lich_chieu"]?["thoi_gian_chieu"];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _navigateToTicketDetail(ticket),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      movieData?["url_poster"] != null
                                          ? imageBaseUrl +
                                              movieData["url_poster"].toString()
                                          : "https://via.placeholder.com/300",
                                      width: 80,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 80,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(Icons.movie,
                                              color: Colors.grey, size: 40),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color:
                                                    _getStatusBackgroundColor(
                                                        ticket["trang_thai"]),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                _getStatusText(
                                                    ticket["trang_thai"]),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: _getStatusColor(
                                                      ticket["trang_thai"]),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          movieData?["ten_phim"]
                                                  ?.toUpperCase() ??
                                              "PHIM KHÔNG XÁC ĐỊNH",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today,
                                                size: 14,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              _formatDateTime(showtime),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.notifications_active,
                                                    size: 14,
                                                    color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "Nhắc nhở trước 30 phút",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
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
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () =>
                                                  _navigateToTicketDetail(
                                                      ticket),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  side: const BorderSide(
                                                      color: Colors.red),
                                                ),
                                              ),
                                              child: Row(
                                                children: const [
                                                  Text("Chi tiết"),
                                                  SizedBox(width: 4),
                                                  Icon(Icons.arrow_forward,
                                                      size: 16),
                                                ],
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
                          ),
                        );
                      },
                    ),
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
        return Colors.green[700]!;
      case "da_su_dung":
        return Colors.blue[700]!;
      case "da_huy":
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
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
