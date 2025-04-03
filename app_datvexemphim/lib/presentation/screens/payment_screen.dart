import 'package:app_datvexemphim/presentation/screens/home_screen.dart';
import 'package:app_datvexemphim/presentation/screens/payment_fail.dart';
import 'package:app_datvexemphim/presentation/screens/payment_successful.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_datvexemphim/api/api_service.dart';
import 'package:app_datvexemphim/data/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

class PaymentScreen extends StatefulWidget {
  final List<String> selectedSeats;
  final int totalPrice;
  final Map<String, int> selectedFoods;
  final List<dynamic> foods;
  final Map<String, dynamic> selectedMovie;
  final String idDonDatVe;

  const PaymentScreen({
    super.key,
    required this.selectedSeats,
    required this.totalPrice,
    required this.selectedFoods,
    required this.foods,
    required this.selectedMovie,
    required this.idDonDatVe,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  String selectedPaymentMethod = "Ví điện tử MoMo"; // Default
  final TextEditingController _promoCodeController = TextEditingController();
  String? _promoMessage;
  int _discount = 0;
  int _discountRank = 0;
  int _finalPrice = 0;
  bool isLoading = false;
  bool isCompleted = false;

  // Animation controller for section transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String userRank = "Basic"; // Default
  double rankDiscount = 0.00; // Default no discount

  // List of payment methods with icons
  final List<Map<String, dynamic>> paymentMethods = [
    {
      "name": "Ví điện tử MoMo",
      "icon": Icons.account_balance_wallet_rounded,
      "color": Color(0xFFAE2070)
    },
    {
      "name": "Thẻ ngân hàng",
      "icon": Icons.credit_card_rounded,
      "color": Color(0xFF2196F3)
    },
    {
      "name": "Thẻ tín dụng",
      "icon": Icons.payment_rounded,
      "color": Color(0xFF4CAF50)
    },
    {
      "name": "ZaloPay",
      "icon": Icons.account_balance_wallet_rounded,
      "color": Color(0xFF0068FF)
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserRank();
    _finalPrice = widget.totalPrice;

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
    _promoCodeController.dispose();
    super.dispose();
  }

  // Format currency
  String formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }

  // Promo code list
  final Map<String, int> promoCodes = {
    "MOMO50K": 50000,
    "GIAM10": 10000,
    "GIAM20": 20000,
    "WELCOME": 15000,
    "PHIMHAY": 30000,
  };

  // Apply promo code with animation
  void _applyPromoCode() {
    String code = _promoCodeController.text.trim().toUpperCase();

    _animationController.reverse().then((_) {
      setState(() {
        if (promoCodes.containsKey(code)) {
          _discount = promoCodes[code]!;
          _finalPrice = _calculateFinalPrice();
          _promoMessage = "✅ Mã giảm giá áp dụng thành công!";
        } else {
          _discount = 0;
          _finalPrice = _calculateFinalPrice();
          _promoMessage = "❌ Mã giảm giá không hợp lệ!";
        }
      });
      _animationController.forward();
    });
  }

  // Calculate final price considering all discounts
  int _calculateFinalPrice() {
    int totalDiscount = _discount + _discountRank;
    return (widget.totalPrice - totalDiscount).clamp(0, widget.totalPrice);
  }

  // Handle payment confirmation
  void _confirmPayment() async {
    setState(() {
      isLoading = true;
    });

    final Map<String, dynamic> body = {
      "amount": _finalPrice,
      "orderInfo":
          "Thanh toán vé xem phim - ${widget.selectedMovie["ten_phim"]}"
    };

    try {
      final response = await ApiService.post('/payment', body);

      if (response != null && response.statusCode == 200) {
        final Map<String, dynamic> result = response.data;
        final String payUrl = result['payUrl'];
        final String orderId = result['orderId'];

        final Uri url = Uri.parse(payUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          throw 'Không thể mở URL: $payUrl';
        }

        bool isPaid = false;
        while (!isPaid) {
          await Future.delayed(Duration(seconds: 2));

          final statusResponse = await ApiService.post(
            '/transaction-status',
            {"orderId": orderId},
          );

          if (statusResponse != null && statusResponse.statusCode == 200) {
            final Map<String, dynamic> statusResult = statusResponse.data;
            final int resultCode = statusResult['resultCode'];

            if (resultCode == 0) {
              isPaid = true;
              isCompleted = true;

              final updateResponse = await ApiService.put(
                '/book/thanhtoan',
                {'idDonDatVe': widget.idDonDatVe},
              );

              if (updateResponse != null && updateResponse.statusCode == 200) {
                await _updateRewardPoints();
                await _sendEmailReceipt();
                if (!isCompleted) return;
                setState(() => isLoading = false);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentSuccessful(),
                  ),
                );
              } else {
                if (!isCompleted) return;
                setState(() => isLoading = false);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentFail(),
                  ),
                );
              }
            } else if (resultCode == 1) {
              isPaid = true;
              isCompleted = true;
              setState(() => isLoading = false);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentFail(),
                ),
              );
            }
          }
        }
      } else {
        throw 'Lỗi khi thanh toán: ${response!.data}';
      }
    } catch (e) {
      print("❌ Lỗi: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi thanh toán!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void startPaymentProcess() {
    _confirmPayment();

    // Nếu sau 5 phút vẫn chưa nhận được phản hồi hợp lệ, tự động chuyển sang PaymentFail
    Future.delayed(Duration(minutes: 5), () {
      if (!isCompleted) {
        setState(() => isLoading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PaymentFail()),
        );
      }
    });
  }

  // Send email receipt
  Future<void> _sendEmailReceipt() async {
    try {
      final emailResponse = await ApiService.post('/send-email', {
        "idDonDatVe": widget.idDonDatVe,
      });

      if (emailResponse != null && emailResponse.statusCode == 200) {
        print("✅ Email đơn vé đã được gửi thành công!");
      } else {
        print("❌ Lỗi khi gửi email: ${emailResponse?.data}");
      }
    } catch (e) {
      print("❌ Lỗi gửi email: $e");
    }
  }

  // Update reward points
  Future<void> _updateRewardPoints() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null) {
        print("❌ Không tìm thấy userId trong SharedPreferences!");
        return;
      }

      final response = await ApiService.post('/user/updatePoint', {
        "id_nguoi_dung": userId,
        "id_don_dat_ve": widget.idDonDatVe,
      });

      if (response != null && response.statusCode == 200) {
        final Map<String, dynamic> result = response.data;
        print(
            "✅ Cập nhật điểm thưởng thành công: ${result['diemTichLuy']} điểm, Rank: ${result['rank']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "🎉 Bạn đã nhận được ${result['diemTichLuy']} điểm thưởng! Cấp bậc mới: ${result['rank']}"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        print("❌ Lỗi khi cập nhật điểm thưởng: ${response?.data}");
      }
    } catch (e) {
      print("❌ Lỗi cập nhật điểm thưởng: $e");
    }
  }

  // Rank discount mapping
  final Map<String, double> rankDiscounts = {
    "Basic": 0.00,
    "Silver": 0.05,
    "Gold": 0.07,
    "Diamond": 0.10,
    "VIP": 0.20,
  };

  // Apply rank discount
  void _applyRankDiscount() {
    setState(() {
      _discountRank = (widget.totalPrice * rankDiscount).toInt();
      _finalPrice = _calculateFinalPrice();
    });
  }

  // Fetch user rank
  Future<void> _fetchUserRank() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null) return;

      final response = await ApiService.get('/user/$userId');

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        setState(() {
          userRank = data['data']['rank'];
          rankDiscount = rankDiscounts[userRank] ?? 0.00;
        });

        _applyRankDiscount();
      }
    } catch (e) {
      print("❌ Lỗi lấy rank: $e");
    }
  }

  // Get rank color based on user rank
  Color _getRankColor(String rank) {
    switch (rank) {
      case "Silver":
        return Colors.grey.shade400;
      case "Gold":
        return Colors.amber;
      case "Diamond":
        return Colors.lightBlueAccent;
      case "VIP":
        return Colors.purple;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Xác nhận & Thanh toán",
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
      body: Stack(
        children: [
          _buildHeaderGradient(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 120.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildUserRankBadge(),
                    const SizedBox(height: 24),
                    _buildSectionTitle("🎬 Thông tin vé"),
                    const SizedBox(height: 12),
                    _buildTicketDetails(),
                    const SizedBox(height: 32),
                    _buildSectionTitle("💰 Thông tin thanh toán"),
                    const SizedBox(height: 12),
                    _buildPriceDetails(),
                    const SizedBox(height: 32),
                    _buildSectionTitle("🏷️ Mã giảm giá"),
                    const SizedBox(height: 12),
                    _buildPromoCodeField(),
                    const SizedBox(height: 32),
                    _buildSectionTitle("💳 Phương thức thanh toán"),
                    const SizedBox(height: 12),
                    _buildPaymentMethodSelection(),
                    const SizedBox(height: 100),
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

  // User rank badge with modern design
  Widget _buildUserRankBadge() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _getRankColor(userRank).withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
              spreadRadius: 0,
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _getRankColor(userRank).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.military_tech_rounded,
                color: _getRankColor(userRank),
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Text(
              "Thành viên $userRank",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (userRank != "Basic") ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _getRankColor(userRank).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "-${(rankDiscount * 100).toInt()}%",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getRankColor(userRank),
                  ),
                ),
              ),
            ],
          ],
        ),
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
  Widget _buildTicketDetails() {
    String imageBaseUrl = "https://rapchieuphim.com";
    String fullImageUrl = (widget.selectedMovie["url_poster"] != null &&
            widget.selectedMovie["url_poster"].isNotEmpty)
        ? imageBaseUrl + widget.selectedMovie["url_poster"]
        : "https://example.com/default_movie.jpg";

    String cinema = widget.selectedMovie["ten_rap"] ?? "Không rõ rạp";
    String movieTitle = widget.selectedMovie["ten_phim"] ?? "Không có tên";
    String showtimeDate =
        formatShowtime(widget.selectedMovie["thoi_gian_chieu"]);
    String format = widget.selectedMovie["dinh_dang"] ?? "2D Phụ Đề";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
            spreadRadius: 0,
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

          // Divider
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.shade200,
                  Colors.transparent
                ],
              ),
            ),
          ),

          // Food items
          if (widget.selectedFoods.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.fastfood_rounded,
                            size: 16, color: Colors.amber),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Combo bắp nước",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...widget.selectedFoods.entries.map((entry) {
                    var food = widget.foods.firstWhere(
                        (f) => f["_id"] == entry.key,
                        orElse: () => {});
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
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              formatCurrency((food["gia"] ?? 0) * entry.value),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB81D24)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Price details box with modern design

  // Price details box
  Widget _buildPriceDetails() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
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
                "Tổng tiền gốc:",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                formatCurrency(widget.totalPrice),
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Rank discount
          if (_discountRank > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    children: [
                      TextSpan(text: "Giảm giá thành viên "),
                      TextSpan(
                        text: "($userRank)",
                        style: TextStyle(
                          color: _getRankColor(userRank),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: ":"),
                    ],
                  ),
                ),
                Text(
                  "- ${formatCurrency(_discountRank)}",
                  style: TextStyle(fontSize: 14, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Promo discount
          if (_discount > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Giảm giá mã khuyến mãi:",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(
                  "- ${formatCurrency(_discount)}",
                  style: TextStyle(fontSize: 14, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

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
                formatCurrency(_finalPrice),
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

  // Promo code input field
  Widget _buildPromoCodeField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoCodeController,
                  decoration: InputDecoration(
                    hintText: "Nhập mã giảm giá",
                    prefixIcon: Icon(Icons.discount, color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFFB81D24)),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _applyPromoCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB81D24),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                child: Text("Áp dụng"),
              ),
            ],
          ),
          if (_promoMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _discount > 0 ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _discount > 0 ? Colors.green[200]! : Colors.red[200]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _discount > 0 ? Icons.check_circle : Icons.error,
                    color: _discount > 0 ? Colors.green : Colors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _promoMessage!,
                      style: TextStyle(
                        color:
                            _discount > 0 ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            "Mã khuyến mãi có sẵn: MOMO50K, GIAM10, GIAM20, WELCOME, PHIMHAY",
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Payment method selection
  Widget _buildPaymentMethodSelection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: paymentMethods.map((method) {
          bool isSelected = selectedPaymentMethod == method["name"];
          return InkWell(
            onTap: () {
              setState(() {
                selectedPaymentMethod = method["name"];
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: paymentMethods.last["name"] == method["name"]
                        ? Colors.transparent
                        : Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: method["color"].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      method["icon"],
                      color: method["color"],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      method["name"],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Radio<String>(
                    value: method["name"],
                    groupValue: selectedPaymentMethod,
                    activeColor: Color(0xFFB81D24),
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Loading overlay with animation and text
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            SizedBox(height: 20),
            Text(
              "Đang xử lý thanh toán...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
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

// Bottom payment bar with animation and gradient
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
                      formatCurrency(_finalPrice),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB81D24),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: userRank != "Basic"
                        ? _getRankColor(userRank).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: userRank != "Basic"
                          ? _getRankColor(userRank)
                          : Colors.transparent,
                    ),
                  ),
                  child: userRank != "Basic"
                      ? Text(
                          "Giảm ${(rankDiscount * 100).toInt()}% thành viên $userRank",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getRankColor(userRank),
                          ),
                        )
                      : SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Payment button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : startPaymentProcess,
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
                  children: const [
                    Icon(Icons.payment),
                    SizedBox(width: 8),
                    Text(
                      "Thanh Toán Ngay",
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
                  "Thanh toán an toàn & bảo mật",
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

// Format showtime from API date to user-friendly format
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
      print("❌ Error formatting date: $e");
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
}
