import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_datvexemphim/api/api_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DetailsTicketScreen extends StatefulWidget {
  final dynamic ticketData;

  const DetailsTicketScreen({Key? key, required this.ticketData})
      : super(key: key);

  @override
  State<DetailsTicketScreen> createState() => _DetailsTicketScreenState();
}

class _DetailsTicketScreenState extends State<DetailsTicketScreen> {
  bool isLoading = true;
  Map<String, dynamic> ticketDetails = {};
  String? errorMessage;
  final String imageBaseUrl = "https://rapchieuphim.com";

  @override
  void initState() {
    super.initState();
    _fetchTicketDetails();
  }

  Future<void> _fetchTicketDetails() async {
    final String ticketId = widget.ticketData["_id"] ?? "";

    if (ticketId.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = "Không tìm thấy mã vé";
      });
      return;
    }

    try {
      final response = await ApiService.get("/ticket/detailticket/$ticketId");

      if (response?.statusCode == 200 && response?.data != null) {
        setState(() {
          ticketDetails = response!.data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Không thể lấy thông tin vé";
        });
      }
    } catch (e) {
      print("❌ Lỗi khi lấy chi tiết vé: $e");
      setState(() {
        isLoading = false;
        errorMessage = "Đã xảy ra lỗi khi tải thông tin vé";
      });
    }
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return "Chưa xác định";
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
      String formattedTime = DateFormat('HH:mm').format(dateTime);
      return "$formattedDate · $formattedTime";
    } catch (e) {
      return "Chưa xác định";
    }
  }

  String _calculateEndTime(String? startTimeStr, int durationMinutes) {
    if (startTimeStr == null) return "Chưa xác định";
    try {
      final dateTime = DateTime.parse(startTimeStr);
      String formattedStartTime = DateFormat('HH:mm').format(dateTime);

      List<String> parts = formattedStartTime.split(':');
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);

      int totalMinutes = hours * 60 + minutes + durationMinutes;
      int endHours = (totalMinutes ~/ 60) % 24;
      int endMinutes = totalMinutes % 60;

      return "${endHours.toString().padLeft(2, '0')}:${endMinutes.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Chưa xác định";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chi Tiết Vé",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF8B5CF6), // Màu tím nhạt đẹp hơn
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 60, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _fetchTicketDetails,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Thử lại"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : _buildTicketDetails(),
    );
  }

  Widget _buildTicketDetails() {
    // Trích xuất dữ liệu từ response API
    var movieData = ticketDetails["id_lich_chieu"]?["id_phim"];
    var showtime = ticketDetails["id_lich_chieu"]?["thoi_gian_chieu"];
    var ticketId = ticketDetails["_id"] ?? "Không xác định";
    var seats = ticketDetails["danh_sach_ghe"] ?? [];
    var foods = ticketDetails["danh_sach_do_an"] ?? [];
    var movieDuration = movieData?["thoi_luong"] ??
        120; // Lấy từ thời lượng phim hoặc mặc định 120 phút

    // Chuẩn bị URL ảnh poster
    String posterUrl = movieData?["url_poster"] != null
        ? imageBaseUrl + movieData["url_poster"]
        : "https://via.placeholder.com/300";

    // Lấy danh sách ghế
    String seatList = seats.isNotEmpty
        ? seats.map((seat) => seat["so_ghe"]).toList().join(", ")
        : "Không có thông tin ghế";

    // Lấy danh sách đồ ăn
    String foodList = foods.isNotEmpty
        ? foods
            .map((food) => "${food["ten_do_an"]} (x${food["so_luong"]})")
            .toList()
            .join(", ")
        : "Không có đồ ăn";

    String startTime = DateFormat('HH:mm')
        .format(DateTime.parse(showtime ?? DateTime.now().toString()));
    String endTime = _calculateEndTime(showtime, movieDuration);
    String showTimeRange = "$startTime - $endTime";

    // Định dạng giá tiền
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    String totalPrice = formatCurrency.format(ticketDetails["tong_tien"] ?? 0);
    String discountAmount =
        formatCurrency.format(ticketDetails["tien_giam"] ?? 0);
    String finalAmount =
        formatCurrency.format(ticketDetails["tien_thanh_toan"] ?? 0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.grey[50]!],
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Phần header - Poster và tên phim
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  // Poster phim
                  Center(
                    child: Hero(
                      tag: 'movie-poster-$ticketId',
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            posterUrl,
                            height: 220,
                            width: 160,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print("❌ Lỗi tải ảnh: $error - URL: $posterUrl");
                              return Container(
                                width: 160,
                                height: 220,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.movie,
                                        color: Colors.grey, size: 50),
                                    SizedBox(height: 12),
                                    Text(
                                      "Không tải được ảnh",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tên phim
                  Text(
                    movieData?["ten_phim"]?.toUpperCase() ??
                        "PHIM KHÔNG XÁC ĐỊNH",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Trạng thái vé
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getStatusBgColor(ticketDetails["trang_thai"]),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color:
                              _getStatusTextColor(ticketDetails["trang_thai"])
                                  .withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _getStatusText(ticketDetails["trang_thai"]),
                      style: TextStyle(
                        color: _getStatusTextColor(ticketDetails["trang_thai"]),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // QR Code
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: QrImageView(
                      data: ticketId,
                      version: QrVersions.auto,
                      size: 180,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                      embeddedImageStyle: QrEmbeddedImageStyle(
                        size: const Size(40, 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Mã vé: $ticketId",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Xuất trình mã QR khi đến rạp",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            // Chi tiết vé
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề phần
                  const Row(
                    children: [
                      Icon(
                        Icons.confirmation_num_rounded,
                        color: Color(0xFF8B5CF6),
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Chi tiết vé",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Divider(color: Colors.grey[200]),
                  const SizedBox(height: 8),

                  // Rạp và phòng
                  _buildInfoSection(
                    icon: Icons.movie_filter_rounded,
                    title: "Tại:",
                    content:
                        "${ticketDetails["id_lich_chieu"]?["id_rap"]?["ten_rap"] ?? "Chưa xác định"} - ${ticketDetails["id_lich_chieu"]?["id_phong"]?["ten_phong"] ?? "Chưa xác định"}",
                  ),

                  // Ngày và giờ chiếu
                  _buildInfoSection(
                    icon: Icons.calendar_today_rounded,
                    title: "Ngày chiếu:",
                    content: showtime != null
                        ? DateFormat('EEEE, dd/MM/yyyy', 'vi_VN')
                            .format(DateTime.parse(showtime))
                        : "Chưa xác định",
                  ),

                  // Giờ chiếu
                  _buildInfoSection(
                    icon: Icons.access_time_rounded,
                    title: "Suất chiếu:",
                    content: showTimeRange,
                  ),

                  // Thông tin ghế
                  _buildInfoSection(
                    icon: Icons.event_seat_rounded,
                    title: "Ghế:",
                    content: seatList,
                  ),

                  // Đồ ăn
                  if (foods.isNotEmpty)
                    _buildInfoSection(
                      icon: Icons.fastfood_rounded,
                      title: "Combo:",
                      content: foodList,
                    ),
                ],
              ),
            ),

            // Thông tin thanh toán
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề phần
                  const Row(
                    children: [
                      Icon(
                        Icons.payment_rounded,
                        color: Color(0xFF8B5CF6),
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Thanh toán",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Divider(color: Colors.grey[200]),
                  const SizedBox(height: 8),

                  // Tổng tiền
                  _buildPaymentRow(
                    title: "Tổng tiền:",
                    amount: totalPrice,
                  ),

                  // Số tiền giảm
                  if ((ticketDetails["tien_giam"] ?? 0) > 0)
                    _buildPaymentRow(
                      title: "Giảm giá:",
                      amount: "- $discountAmount",
                      isDiscount: true,
                    ),

                  // Tổng thanh toán
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Divider(color: Colors.grey[200]),
                  ),
                  _buildPaymentRow(
                    title: "Thành tiền:",
                    amount: finalAmount,
                    isFinal: true,
                  ),

                  // Phương thức thanh toán
                  if (ticketDetails["phuong_thuc_thanh_toan"] != null)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPaymentIcon(
                                ticketDetails["phuong_thuc_thanh_toan"]),
                            size: 18,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Thanh toán qua ${ticketDetails["phuong_thuc_thanh_toan"] ?? "Chưa cập nhật"}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Lưu ý
            Container(
              margin: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        "Lưu ý quan trọng:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildNoteItem(
                      "Vui lòng đến trước giờ chiếu 15-20 phút để không bỏ lỡ phim"),
                  _buildNoteItem("Vé đã mua không được đổi hoặc trả lại"),
                  _buildNoteItem("Xuất trình mã QR khi vào rạp chiếu phim"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.arrow_right_rounded,
            size: 20,
            color: Color(0xFFD97706),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF8B5CF6)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: MediaQuery.of(context).size.width - 120,
                child: Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow({
    required String title,
    required String amount,
    bool isDiscount = false,
    bool isFinal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isFinal ? 16 : 14,
              fontWeight: isFinal ? FontWeight.bold : FontWeight.w500,
              color: isDiscount ? Colors.green[700] : const Color(0xFF4B5563),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isFinal ? 16 : 14,
              fontWeight: isFinal ? FontWeight.bold : FontWeight.w500,
              color: isDiscount
                  ? Colors.green[700]
                  : isFinal
                      ? const Color(0xFF8B5CF6)
                      : const Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(String? method) {
    if (method == null) return Icons.payment_rounded;

    final methodLower = method.toLowerCase();
    if (methodLower.contains("momo"))
      return Icons.account_balance_wallet_rounded;
    if (methodLower.contains("zalopay"))
      return Icons.account_balance_wallet_rounded;
    if (methodLower.contains("vnpay")) return Icons.payment_rounded;
    if (methodLower.contains("thẻ") || methodLower.contains("card"))
      return Icons.credit_card_rounded;
    if (methodLower.contains("chuyển khoản") || methodLower.contains("banking"))
      return Icons.account_balance_rounded;

    return Icons.payment_rounded;
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case "da_thanh_toan":
      case "đã thanh toán":
        return "Đã thanh toán";
      case "da_su_dung":
      case "đã sử dụng":
        return "Đã sử dụng";
      case "da_huy":
      case "đã hủy":
        return "Đã hủy";
      case "dang_cho":
      case "đang chờ":
        return "Đang chờ thanh toán";
      default:
        return "Chưa xác định";
    }
  }

  Color _getStatusBgColor(String? status) {
    switch (status?.toLowerCase()) {
      case "da_thanh_toan":
      case "đã thanh toán":
        return const Color(0xFFDCFCE7);
      case "da_su_dung":
      case "đã sử dụng":
        return const Color(0xFFDBEAFE);
      case "da_huy":
      case "đã hủy":
        return const Color(0xFFFEE2E2);
      case "dang_cho":
      case "đang chờ":
        return const Color(0xFFFEF3C7);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getStatusTextColor(String? status) {
    switch (status?.toLowerCase()) {
      case "da_thanh_toan":
      case "đã thanh toán":
        return const Color(0xFF047857);
      case "da_su_dung":
      case "đã sử dụng":
        return const Color(0xFF1D4ED8);
      case "da_huy":
      case "đã hủy":
        return const Color(0xFFB91C1C);
      case "dang_cho":
      case "đang chờ":
        return const Color(0xFFB45309);
      default:
        return const Color(0xFF4B5563);
    }
  }
}
