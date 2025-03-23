import 'dart:convert';

import 'package:app_datvexemphim/presentation/screens/home_screen.dart';
import 'package:app_datvexemphim/presentation/screens/payment_successful.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentScreen extends StatefulWidget {
  final List<String> selectedSeats;
  final int totalPrice;
  final Map<String, int> selectedFoods;
  final List<dynamic> foods;
  final Map<String, dynamic> selectedMovie;

  const PaymentScreen({
    super.key,
    required this.selectedSeats,
    required this.totalPrice,
    required this.selectedFoods,
    required this.foods,
    required this.selectedMovie,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPaymentMethod = "Ví điện tử MoMo"; // Mặc định
  final TextEditingController _promoCodeController = TextEditingController();
  String? _promoMessage;
  int _discount = 0;
  int _finalPrice = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _finalPrice = widget.totalPrice; // Giá ban đầu = tổng tiền gốc
  }

  // Hàm định dạng tiền tệ
  String formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }

  // Danh sách mã giảm giá hợp lệ
  final Map<String, int> promoCodes = {
    "MOMO50K": 50000,
    "GIAM10": 10000,
    "GIAM20": 20000,
  };

  // Xử lý nhập mã giảm giá
  void _applyPromoCode() {
    String code = _promoCodeController.text.trim().toUpperCase();

    if (promoCodes.containsKey(code)) {
      setState(() {
        _discount = promoCodes[code]!;
        _finalPrice =
            (widget.totalPrice - _discount).clamp(0, widget.totalPrice);
        _promoMessage = "✅ Mã giảm giá áp dụng thành công!";
      });
    } else {
      setState(() {
        _discount = 0;
        _finalPrice = widget.totalPrice;
        _promoMessage = "❌ Mã giảm giá không hợp lệ!";
      });
    }
  }

  // Xử lý khi nhấn thanh toán
  void _confirmPayment() async {
    // const String apiUrl = "http://192.168.1.4:5000/api/v1/payment";

    // final Map<String, dynamic> body = {
    //   "amount": _finalPrice, // Thay bằng giá trị thực tế
    //   "orderInfo": "Thanh toán MoMo test"
    // };

    // try {
    //   final response = await http.post(
    //     Uri.parse(apiUrl),
    //     headers: {"Content-Type": "application/json"},
    //     body: jsonEncode(body),
    //   );

    //   if (response.statusCode == 200) {
    //     final Map<String, dynamic> result = jsonDecode(response.body);
    //     final String payUrl = result['payUrl'];
    //     final String orderId = result['orderId'];

    //     // Hiển thị thông báo
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text(
    //             "Thanh toán thành công với số tiền ${formatCurrency(_finalPrice)}"),
    //       ),
    //     );

    //     // Mở URL trong trình duyệt ngoài
    //     final Uri url = Uri.parse(payUrl);
    //     if (await canLaunchUrl(url)) {
    //       await launchUrl(url, mode: LaunchMode.externalApplication);
    //     } else {
    //       throw 'Không thể mở URL: $payUrl';
    //     }
    //   } else {
    //     throw 'Lỗi khi thanh toán: ${response.body}';
    //   }
    // } catch (e) {
    //   print("Lỗi: $e");
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("Lỗi thanh toán!")),
    //   );
    // }

    const String apiUrl = "http://192.168.1.4:5000/api/v1/payment";
    const String checkStatusUrl =
        "http://192.168.1.4:5000/api/v1/transaction-status";

    setState(() {
      isLoading = true; // Hiển thị vòng xoay
    });

    final Map<String, dynamic> body = {
      "amount": _finalPrice, // Thay bằng giá trị thực tế
      "orderInfo": "Thanh toán MoMo test"
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);
        final String payUrl = result['payUrl'];
        final String orderId = result['orderId'];

        // Mở URL thanh toán trên trình duyệt
        final Uri url = Uri.parse(payUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          throw 'Không thể mở URL: $payUrl';
        }

        // Kiểm tra trạng thái giao dịch sau khi thanh toán
        bool isPaid = false;
        while (!isPaid) {
          await Future.delayed(
              Duration(seconds: 2)); // Chờ 2 giây trước khi kiểm tra lại

          final statusResponse = await http.post(
            Uri.parse(checkStatusUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"orderId": orderId}),
          );

          if (statusResponse.statusCode == 200) {
            final Map<String, dynamic> statusResult =
                jsonDecode(statusResponse.body);
            final int resultCode = statusResult['resultCode'];

            if (resultCode == 0) {
              isPaid = true;
              setState(() => isLoading = false);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PaymentSuccessful()),
              );
            } else if (resultCode == 1) {
              isPaid = true;
              setState(() => isLoading = false);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            }
          }
        }
      } else {
        throw 'Lỗi khi thanh toán: ${response.body}';
      }
    } catch (e) {
      print("Lỗi: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi thanh toán!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Xác nhận và Thanh toán",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("🎬 Thông tin vé",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildTicketDetails(),
            const SizedBox(height: 16),

            // Mã giảm giá
            _buildPromoCodeField(),
            const SizedBox(height: 16),

            // Chọn phương thức thanh toán
            _buildPaymentMethodSelection(),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tổng tiền:",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(formatCurrency(_finalPrice),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmPayment,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffb81d24),
                    minimumSize: const Size(double.infinity, 50)),
                child: const Text("Thanh Toán",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Chi tiết vé phim
  Widget _buildTicketDetails() {
    String imageBaseUrl = "https://rapchieuphim.com";
    String fullImageUrl = (widget.selectedMovie["url_poster"] != null &&
            widget.selectedMovie["url_poster"].isNotEmpty)
        ? imageBaseUrl + widget.selectedMovie["url_poster"]
        : "https://example.com/default_movie.jpg"; // Ảnh mặc định nếu không có poster

    String cinema = widget.selectedMovie["ten_rap"] ?? "Không rõ rạp";
    String movieTitle = widget.selectedMovie["ten_phim"] ?? "Không có tên";
    String showtimeDate =
        formatShowtime(widget.selectedMovie["thoi_gian_chieu"]);
    String format = widget.selectedMovie["dinh_dang"] ?? "2D Phụ Đề";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                offset: Offset(0, 2),
              )
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  fullImageUrl,
                  width: 80,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported, size: 80);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cinema,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(movieTitle,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(format,
                        style: const TextStyle(
                            color: Colors.orange, fontWeight: FontWeight.bold)),
                    Text("Thời gian: $showtimeDate",
                        style: TextStyle(color: Colors.grey[700])),
                    Text("Ghế: ${widget.selectedSeats.join(", ")}",
                        style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Danh sách đồ ăn đã chọn
        if (widget.selectedFoods.isNotEmpty) ...[
          const Text("🍿 Combo bắp nước",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...widget.selectedFoods.entries.map((entry) {
            var food = widget.foods
                .firstWhere((f) => f["_id"] == entry.key, orElse: () => {});
            if (food.isEmpty) return const SizedBox();
            return ListTile(
              leading: Image.network(
                  food["url_hinh"] ?? "https://example.com/default_food.jpg",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover),
              title: Text(food["ten_do_an"] ?? "Chưa xác định"),
              subtitle: Text(formatCurrency((food["gia"] ?? 0) * entry.value)),
              trailing: Text("x${entry.value}"),
            );
          }),
          const Divider(),
        ],
      ],
    );
  }

// ✅ Hàm định dạng thời gian
  String formatShowtime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "Không xác định";
    try {
      DateTime parsedDate = DateTime.parse(dateTime).toLocal();
      DateTime vietnamTime = parsedDate.add(const Duration(hours: 7));
      return DateFormat("HH:mm dd/MM/yyyy").format(vietnamTime);
    } catch (e) {
      return "Không xác định";
    }
  }

  Widget _buildPromoCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("💳 Mã Giảm Giá",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _promoCodeController,
                decoration: InputDecoration(
                  hintText: "Nhập mã giảm giá...",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _applyPromoCode,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text("Áp dụng"),
            ),
          ],
        ),
        if (_promoMessage != null) ...[
          const SizedBox(height: 8),
          Text(_promoMessage!,
              style:
                  TextStyle(color: _discount > 0 ? Colors.green : Colors.red)),
        ],
      ],
    );
  }

  /// PTTT
  Widget _buildPaymentMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("💳 Chọn Phương Thức Thanh Toán",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildPaymentOption("Ví điện tử MoMo"),
        _buildPaymentOption("Thẻ ngân hàng"),
      ],
    );
  }

  Widget _buildPaymentOption(String method) {
    return ListTile(
      leading: Radio<String>(
        value: method,
        groupValue: selectedPaymentMethod,
        onChanged: (String? value) {
          setState(() {
            selectedPaymentMethod = value!;
          });
        },
      ),
      title: Text(method),
    );
  }

  ////
  Widget _buildPaymentButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _confirmPayment,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50)),
          child: const Text("Thanh toán ngay",
              style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }
}
