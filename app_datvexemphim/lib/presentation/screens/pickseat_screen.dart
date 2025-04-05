import 'package:app_datvexemphim/api/api_service.dart';
import 'package:app_datvexemphim/presentation/screens/pickfandb.dart';
import 'package:app_datvexemphim/presentation/size_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_datvexemphim/data/services/storage_service.dart';
// Import the timer service
import 'package:app_datvexemphim/data/services/timer_service.dart';

class PickseatScreen extends StatefulWidget {
  final Map<String, dynamic> schedule;
  const PickseatScreen({super.key, required this.schedule});

  @override
  _PickseatScreenState createState() => _PickseatScreenState();
}

class _PickseatScreenState extends State<PickseatScreen> {
  List<String> bookedSeats = [];
  List<String> selectedSeats = [];
  List<Map<String, dynamic>> availableSeats = []; // Danh sách ghế từ API
  bool isLoading = true;
  String? userId;
  // Timer service instance
  final BookingTimerService _timerService = BookingTimerService();
  String _timeRemaining = "00:10";

  @override
  void initState() {
    super.initState();
    fetchSeatStatus(); // Gọi API lấy trạng thái ghế

    // Add timer listener
    _timerService.addListener(_onTimerUpdate);
    _timeRemaining = _timerService.timeRemainingFormatted;
  }

  @override
  void dispose() {
    // Remove timer listener
    _timerService.removeListener(_onTimerUpdate);
    super.dispose();
  }

  // Timer update callback
  void _onTimerUpdate(int secondsRemaining) {
    setState(() {
      _timeRemaining = _timerService.timeRemainingFormatted;
    });
  }

  // Show session expired dialog
// Show session expired dialog
  void _showSessionExpiredDialog() async {
    if (selectedSeats.isNotEmpty) {
      try {
        userId = await StorageService.getUserId();
        print("ID Lịch Chiếu cần xoá: ${widget.schedule["_id"]}");
        print("ID Người Dùng cần xoá: $userId");
        print("Danh Sách Ghế cần xoá: ${selectedSeats}");

        final response = await ApiService.delete(
          "/book/cancelGhe/$userId",
          data: {
            "idLichChieu": widget.schedule["_id"],
            "danhSachGhe": selectedSeats
          },
        );

        if (response?.statusCode == 200) {
          print("Đã hủy giữ chỗ ghế: ${response?.data}");
        } else {
          print("Lỗi khi hủy giữ chỗ: ${response?.data}");
        }
      } catch (e) {
        print("Lỗi khi gọi API hủy ghế: $e");
      }
    }

    setState(() {
      selectedSeats.clear(); // Xóa danh sách ghế đã chọn
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Phiên đặt vé đã hết hạn'),
          content: const Text(
              'Thời gian đặt vé đã hết. Các ghế đã chọn đã bị hủy. Vui lòng thử lại.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Quay lại'),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchSeatStatus() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.get("/seat/${widget.schedule['_id']}");
      if (response?.statusCode == 200) {
        List<dynamic> seatList = response?.data['danh_sach_ghe'];

        // Sắp xếp ghế theo thứ tự alphabet và số
        List<Map<String, dynamic>> sortedSeats =
            seatList.cast<Map<String, dynamic>>()
              ..sort((a, b) {
                final aSeat = a["so_ghe"];
                final bSeat = b["so_ghe"];

                // Tách phần chữ và số từ mã ghế
                final aMatch = RegExp(r'(\D+)(\d+)').firstMatch(aSeat);
                final bMatch = RegExp(r'(\D+)(\d+)').firstMatch(bSeat);

                final aLetter = aMatch?.group(1) ?? '';
                final aNumber = int.tryParse(aMatch?.group(2) ?? '0') ?? 0;
                final bLetter = bMatch?.group(1) ?? '';
                final bNumber = int.tryParse(bMatch?.group(2) ?? '0') ?? 0;

                // So sánh phần chữ trước
                if (aLetter.compareTo(bLetter) != 0) {
                  return aLetter.compareTo(bLetter);
                }

                // Nếu cùng hàng thì so sánh số
                return aNumber.compareTo(bNumber);
              });

        List<String> booked = seatList
            .where((seat) => seat["trang_thai"] == "đã đặt trước")
            .map<String>((seat) => seat["so_ghe"])
            .toList();
        List<Map<String, dynamic>> available =
            seatList.cast<Map<String, dynamic>>();

        setState(() {
          bookedSeats = booked;
          availableSeats = available; // Cập nhật danh sách ghế có sẵn
          isLoading = false;
        });
      }

      print(response?.data); // Kiểm tra dữ liệu nhận được
      print('id lich chieu: ${widget.schedule['_id']}');
    } catch (e) {
      print("Lỗi khi tải trạng thái ghế: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppSizes().init(context); // Khởi tạo AppSizes
    return WillPopScope(
        onWillPop: () async {
          _showSessionExpiredDialog();
          return false; // Không pop ngay, đợi xử lý xong
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 3,
            backgroundColor: Colors.white,
            shadowColor: Colors.black26,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.schedule["id_rap"]?["ten_rap"] ?? "Tên rạp"),
                Text(
                  "${widget.schedule["id_phong"]?["ten_phong"]} - ${widget.schedule["thoi_gian_chieu"]}",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              // Add timer to the app bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE57373)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Color(0xFFB71C1C), size: 18),
                    const SizedBox(width: 2),
                    Text(
                      _timeRemaining,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    SizedBox(height: AppSizes.blockSizeVertical * 1),
                    _buildScreenIndicator(),
                    SizedBox(height: AppSizes.blockSizeVertical * 1),
                    Expanded(
                      child: SizedBox(
                        width: 100000,
                        child: InteractiveViewer(
                          boundaryMargin: const EdgeInsets.all(20),
                          minScale: 0.0000005,
                          maxScale: 3.0,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: _buildSeatMap(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizes.blockSizeVertical * 1),
                    _buildSeatLegend(),
                  ],
                ),
          bottomNavigationBar: _buildBottomNavBar(),
        ));
  }

  Widget _buildScreenIndicator() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: AppSizes.blockSizeVertical * 1),
      child: Column(
        children: [
          CustomPaint(
            size: const Size(double.infinity, 50),
            painter: ScreenPainter(),
          ),
          const SizedBox(height: 5),
          Text(
            "MÀN HÌNH",
            style: TextStyle(
              color: Colors.black,
              fontSize: AppSizes.blockSizeHorizontal * 4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatLegend() {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.blockSizeVertical * 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(const Color(0xffb7b7b7), "Ghế trống"),
          _buildLegendItem(Colors.red, "Ghế đã đặt"),
          _buildLegendItem(Colors.green, "Ghế đang chọn"),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: AppSizes.blockSizeHorizontal * 5,
          height: AppSizes.blockSizeHorizontal * 5,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(4)),
        ),
        SizedBox(width: AppSizes.blockSizeHorizontal * 1),
        Text(
          label,
          style: TextStyle(fontSize: AppSizes.blockSizeHorizontal * 3.5),
        ),
      ],
    );
  }

  Widget _buildSeatMap() {
    double seatWidth = AppSizes.blockSizeHorizontal * 6;
    double seatHeight = AppSizes.blockSizeHorizontal * 6;
    double seatMargin = AppSizes.blockSizeHorizontal * 1;

    // Nhóm ghế theo hàng
    final Map<String, List<Map<String, dynamic>>> groupedSeats = {};
    for (var seat in availableSeats) {
      final seatNumber = seat["so_ghe"];
      final row = seatNumber.replaceAll(RegExp(r'\d+'), '');
      groupedSeats.putIfAbsent(row, () => []).add(seat);
    }

    return Column(
      children: groupedSeats.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: entry.value.map((seat) {
            String seatLabel = seat["so_ghe"];
            bool isBooked = bookedSeats.contains(seatLabel);
            bool isSelected = selectedSeats.contains(seat["_id_Ghe"]);

            return GestureDetector(
              onTap:
                  isBooked ? null : () => _toggleSeatSelection(seat["_id_Ghe"]),
              child: Container(
                width: seatWidth,
                height: seatHeight,
                margin: EdgeInsets.all(seatMargin),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isBooked
                      ? Colors.red
                      : isSelected
                          ? Colors.green
                          : const Color(0xffb7b7b7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  seatLabel,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: AppSizes.blockSizeHorizontal * 2.0),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  void _toggleSeatSelection(String seatId) {
    setState(() {
      if (selectedSeats.contains(seatId)) {
        selectedSeats.remove(seatId);
      } else {
        selectedSeats.add(seatId);
      }
    });
  }

  String formatCurrency(int amount) {
    return NumberFormat("#,###", "vi_VN").format(amount);
  }

  Widget _buildBottomNavBar() {
    int ticketPrice = widget.schedule["gia_ve"] ?? 0;
    int totalPrice = selectedSeats.length * ticketPrice;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppSizes.blockSizeHorizontal * 5,
          vertical: AppSizes.blockSizeVertical * 2),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, -3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.schedule["id_phim"]?["ten_phim"] ?? "Tên phim",
                style: TextStyle(
                    color: const Color(0xffb81d24),
                    fontSize: AppSizes.blockSizeHorizontal * 4,
                    fontWeight: FontWeight.bold),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Tổng: ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: AppSizes.blockSizeHorizontal * 4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: "${formatCurrency(totalPrice)}đ", // Cập nhật
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: AppSizes.blockSizeHorizontal * 4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.blockSizeVertical * 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Số ghế đã chọn: ${selectedSeats.length}",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: AppSizes.blockSizeHorizontal * 3.5),
              ),
              ElevatedButton(
                onPressed: selectedSeats.isEmpty ? null : _bookTickets,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffb20710)),
                child: Text(
                  "Tiếp tục",
                  style: TextStyle(
                      fontSize: AppSizes.blockSizeHorizontal * 4,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _bookTickets() async {
    // Start the timer when user clicks "Tiếp tục"
    _timerService.startTimer(onTimeExpired: _showSessionExpiredDialog);

    userId = await StorageService.getUserId();

    if (selectedSeats.isEmpty) return;

    int totalPrice =
        (selectedSeats.length * (widget.schedule["gia_ve"] ?? 0)).toInt();
    print("Danh sách ghế đã chọn: $selectedSeats");
    print("id lich chieu da chọn: ${widget.schedule["_id"]}");

    try {
      final response = await ApiService.post("/book/chonGhe", {
        "idLichChieu": widget.schedule["_id"],
        "danhSachGhe": selectedSeats, // Gửi ID của ghế
        "idUser": userId, // Truyền idUser của người dùng
        // "tong_tien": totalPrice,
      });

      if (response?.statusCode == 200) {
        print("Đặt ghế thành công: ${response?.data}");
        setState(() {
          bookedSeats.addAll(selectedSeats);
          // selectedSeats.clear();
        });

        // Chuyển đến màn hình chọn combo
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            print("Chuyển đến ComboSelectionScreen với ghế: $selectedSeats");
            return ComboSelectionScreen(
              selectedSeats: selectedSeats, // Truyền danh sách ID ghế
              totalPrice: totalPrice,
              selectedMovie: {
                "id_lich_chieu": widget.schedule["_id"],
                "ten_phim":
                    widget.schedule["id_phim"]?["ten_phim"] ?? "Tên phim",
                "thoi_luong": widget.schedule["id_phim"]?["thoi_luong"] ?? 0,
                "thoi_gian_chieu":
                    widget.schedule["thoi_gian_chieu"] ?? "Không rõ",
                "url_poster": widget.schedule["id_phim"]?["url_poster"],
                "ten_rap": widget.schedule["id_rap"]?["ten_rap"],
              },
            );
          }),
        );
      } else {
        print("Lỗi đặt ghế: ${response?.data}");
      }
    } catch (e) {
      print("Lỗi khi gọi API đặt ghế: $e");
    }
  }
}

class ScreenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.red // Màu viền màn hình
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    Path path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height);

    canvas.drawPath(path, paint);

    Rect rect =
        Rect.fromLTWH(0, -size.height * 0.5, size.width, size.height * 1.5);
    Gradient gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFee0033),
        Color.fromARGB(244, 250, 112, 142),
        Color.fromARGB(204, 247, 136, 160),
        Color.fromARGB(126, 243, 182, 195).withOpacity(0.8),
        const Color.fromARGB(0, 255, 255, 255),
      ],
    );

    Paint fillPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    Path fillPath = Path();
    fillPath.moveTo(0, size.height);
    fillPath.quadraticBezierTo(size.width / 2, 0, size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
