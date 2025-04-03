import 'package:app_datvexemphim/api/api_service.dart';
import 'package:app_datvexemphim/data/services/storage_service.dart';
import 'package:app_datvexemphim/presentation/screens/payment_screen.dart'
    show PaymentScreen;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class DetailsTicket extends StatefulWidget {
  final List<String> selectedSeats;
  final List<String> seatLabel;
  final int totalPrice;
  final Map<String, int> selectedFoods;
  final List<dynamic> foods;
  final Map<String, dynamic> selectedMovie;

  const DetailsTicket({
    super.key,
    required this.seatLabel,
    required this.selectedSeats,
    required this.totalPrice,
    required this.selectedFoods,
    required this.foods,
    required this.selectedMovie,
    required String movieId,
    required selectedShowtime,
  });

  @override
  _DetailsTicketState createState() => _DetailsTicketState();
}

class _DetailsTicketState extends State<DetailsTicket>
    with SingleTickerProviderStateMixin {
  String? userId;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    print("ID lịch chiếu: ${widget.selectedMovie['id_lich_chieu']}");
    print("Danh sách ghế: ${widget.selectedSeats.join(", ")}");
    print("Danh sách đồ ăn: ${widget.selectedFoods.keys.join(", ")}");

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }

  String formatShowtime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "Không xác định";
    try {
      // Parse the original datetime string
      DateTime parsedDate = DateTime.parse(dateTime);

      // Convert to local time zone (adding Vietnam's timezone offset +7)
      DateTime vietnamTime = parsedDate.add(const Duration(hours: 7));

      // Format the date and time in a user-friendly way
      String formattedTime = DateFormat("HH:mm").format(vietnamTime);
      String formattedDate = DateFormat("dd/MM/yyyy").format(vietnamTime);
      String dayName = _getVietnameseDayName(vietnamTime.weekday);

      // Create the final formatted string
      return "$formattedTime • $dayName, $formattedDate";
    } catch (e) {
      return "Không xác định";
    }
  }

  // Helper function to get Vietnamese day names
  String _getVietnameseDayName(int weekday) {
    switch (weekday) {
      case 1:
        return "Thứ Hai";
      case 2:
        return "Thứ Ba";
      case 3:
        return "Thứ Tư";
      case 4:
        return "Thứ Năm";
      case 5:
        return "Thứ Sáu";
      case 6:
        return "Thứ Bảy";
      case 7:
        return "Chủ Nhật";
      default:
        return "";
    }
  }

  Future<void> _confirmBooking(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    userId = await StorageService.getUserId();
    print('id nguoi dung $userId');
    if (userId == null) {
      setState(() {
        isLoading = false;
      });
      _showErrorMessage("Không tìm thấy ID người dùng.");
      return;
    }

    try {
      final response = await ApiService.post("/book/xacNhanDatVe", {
        "idNguoiDung": userId,
        "idLichChieu": widget.selectedMovie["id_lich_chieu"],
        "danhSachGhe": widget.selectedSeats,
        "danhSachDoAn": widget.selectedFoods.keys.join(", "),
      });

      if (response?.statusCode == 200) {
        print("Đặt vé thành công: ${response?.data}");

        // Lấy `idDonDatVe` từ phản hồi API
        String? idDonDatVe = response?.data["idDonDatVe"];

        if (idDonDatVe == null || idDonDatVe.isEmpty) {
          setState(() {
            isLoading = false;
          });
          _showErrorMessage("Lỗi: idDonDatVe không hợp lệ.");
          return;
        }

        // In thông tin vào terminal
        print("ID đơn đặt vé: $idDonDatVe");
        print("ID lịch chiếu: ${widget.selectedMovie['id_lich_chieu']}");
        print("Danh sách ghế: ${widget.selectedSeats.join(", ")}");
        print("Danh sách đồ ăn: ${widget.selectedFoods.keys.join(", ")}");

        setState(() {
          isLoading = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              selectedSeats: widget.selectedSeats,
              totalPrice: widget.totalPrice,
              selectedFoods: widget.selectedFoods,
              foods: widget.foods,
              selectedMovie: widget.selectedMovie,
              idDonDatVe: idDonDatVe,
            ),
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorMessage(
            "Lỗi khi xác nhận đặt vé: ${response?.data['message']}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorMessage("Lỗi khi gọi API xác nhận đặt vé: $e");
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String cinema = widget.selectedMovie["ten_rap"] ?? "Không rõ rạp";
    String movieTitle = widget.selectedMovie["ten_phim"] ?? "Không có tên";
    String format = widget.selectedMovie['dinh_dang'] ?? "2D Phụ Đề";
    String showtimeDate =
        formatShowtime(widget.selectedMovie['thoi_gian_chieu']);

    String imageBaseUrl = "https://rapchieuphim.com";
    String fullImageUrl =
        imageBaseUrl + (widget.selectedMovie["url_poster"] ?? "");

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Thông tin thanh toán",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black12,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          _buildHeaderGradient(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 120.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAlertBox(),
                    const SizedBox(height: 24),
                    _buildSectionTitle("🎬 Thông tin vé"),
                    const SizedBox(height: 12),
                    _buildTicketDetails(
                        fullImageUrl, cinema, movieTitle, format, showtimeDate),
                    const SizedBox(height: 32),
                    if (widget.selectedFoods.isNotEmpty) ...[
                      _buildSectionTitle("🍿 Combo bắp nước"),
                      const SizedBox(height: 12),
                      _buildFoodDetails(),
                      const SizedBox(height: 32),
                    ],
                    _buildSectionTitle("💰 Thông tin thanh toán"),
                    const SizedBox(height: 12),
                    _buildPriceDetails(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading) _buildLoadingOverlay(),
        ],
      ),
      bottomSheet: _buildBottomPaymentBar(),
    );
  }

  // Header gradient with blur effect
  Widget _buildHeaderGradient() {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFB81D24),
            Color(0xFFB81D24).withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  // Alert box with modern design
  Widget _buildAlertBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFFFFE0E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.info_outline, color: Color(0xFFB81D24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Lưu ý quan trọng",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Vé đã mua không thể hoàn, huỷ, đổi. Vui lòng kiểm tra kỹ thông tin!",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Section title with modern design
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade300,
                    Colors.grey.shade100,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Movie ticket details with modern design
  Widget _buildTicketDetails(String fullImageUrl, String cinema,
      String movieTitle, String format, String showtimeDate) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          // Movie details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey.shade50],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                // Movie poster with reflection effect
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          fullImageUrl,
                          width: 100,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100,
                              height: 150,
                              color: Colors.grey[200],
                              child: Icon(Icons.movie_rounded,
                                  size: 40, color: Colors.grey[400]),
                            );
                          },
                        ),
                      ),
                    ),
                    // Reflection overlay
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 80,
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(12)),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Movie info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 14, color: Color(0xFFB81D24)),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              cinema,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        movieTitle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // Format badge
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Text(
                          format,
                          style: TextStyle(
                            color: Colors.amber[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Date and time
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Color(0xFFB81D24).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(Icons.calendar_today_rounded,
                                size: 14, color: Color(0xFFB81D24)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              showtimeDate,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Seat info
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(Icons.event_seat_rounded,
                                size: 14, color: Colors.green),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Ghế: ${widget.selectedSeats.join(", ")}",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
        ],
      ),
    );
  }

  // Food details with modern design
  Widget _buildFoodDetails() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: widget.selectedFoods.entries.map((entry) {
          var food = widget.foods
              .firstWhere((f) => f["_id"] == entry.key, orElse: () => {});
          if (food.isEmpty) return const SizedBox();

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      food["url_hinh"] ??
                          "https://example.com/default_food.jpg",
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: Icon(Icons.fastfood_rounded,
                              color: Colors.grey[400]),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food["ten_do_an"] ?? "Chưa xác định",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "${formatCurrency((food["gia"] ?? 0))} x ${entry.value}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    formatCurrency((food["gia"] ?? 0) * entry.value),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB81D24),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Price details box
  Widget _buildPriceDetails() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Original price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tổng tiền:",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                formatCurrency(widget.totalPrice),
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Divider
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 8),

          // Final price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Thành tiền:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                formatCurrency(widget.totalPrice),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFFB81D24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Loading overlay with animation
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            Text(
              "Đang xử lý...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Vui lòng không tắt ứng dụng",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom payment bar
  Widget _buildBottomPaymentBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Price summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tổng thanh toán",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(widget.totalPrice),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB81D24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Continue button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _confirmBooking(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB81D24),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_forward),
                    const SizedBox(width: 8),
                    Text(
                      "Tiếp Tục",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Security note
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  "Bảo mật thông tin thanh toán",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
