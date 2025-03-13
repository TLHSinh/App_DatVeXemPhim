import 'package:app_datvexemphim/api/api_service.dart';
import 'package:app_datvexemphim/presentation/screens/pickfandb.dart';
import 'package:app_datvexemphim/presentation/size_config.dart';
import 'package:flutter/material.dart';
// Import AppSizes

class PickseatScreen extends StatefulWidget {
  final Map<String, dynamic> schedule;
  const PickseatScreen({super.key, required this.schedule});

  @override
  _PickseatScreenState createState() => _PickseatScreenState();
}

class _PickseatScreenState extends State<PickseatScreen> {
  final int rows = 8;
  final int cols = 15;
  List<String> bookedSeats = [];
  List<String> selectedSeats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSeatStatus(); // Gọi API lấy trạng thái ghế
  }

  Future<void> fetchSeatStatus() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.get("/seat/${widget.schedule['_id']}");
      if (response?.statusCode == 200) {
        List<dynamic> seatList = response?.data['danh_sach_ghe'];
        List<String> booked = seatList
            .where((seat) => seat["trang_thai"] == "đã đặt")
            .map<String>((seat) => seat["so_ghe"])
            .toList();

        setState(() {
          bookedSeats = booked;
          isLoading = false;
        });
      }
      print(response?.data); // Kiểm tra dữ liệu nhận được
    } catch (e) {
      print("Lỗi khi tải trạng thái ghế: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppSizes().init(context); // Khởi tạo AppSizes
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      appBar: AppBar(
        elevation: 3,
        backgroundColor: Colors.white,
        shadowColor: Colors.black26,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.schedule["id_rap"]?["ten_rap"] ?? "Tên rạp"),
            Text(
              "${widget.schedule["id_phong"]?["ten_phong"]} - ${widget.schedule["ngay_gio"]}",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(
                    height: AppSizes.blockSizeVertical *
                        1), // 1% chiều cao màn hình
                _buildScreenIndicator(),
                SizedBox(
                    height: AppSizes.blockSizeVertical *
                        1), // 1% chiều cao màn hình
                Expanded(child: _buildSeatMap()),
                SizedBox(
                    height: AppSizes.blockSizeVertical *
                        1), // 1% chiều cao màn hình
                _buildSeatLegend(),
              ],
            ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildScreenIndicator() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          vertical: AppSizes.blockSizeVertical * 1), // 1% chiều cao màn hình
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        "MÀN HÌNH",
        style: TextStyle(
            color: Colors.black,
            fontSize:
                AppSizes.blockSizeHorizontal * 4, // 4% chiều rộng màn hình
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSeatLegend() {
    return Padding(
      padding: EdgeInsets.only(
          bottom: AppSizes.blockSizeVertical * 1), // 1% chiều cao màn hình
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
          width: AppSizes.blockSizeHorizontal * 5, // 5% chiều rộng màn hình
          height: AppSizes.blockSizeHorizontal * 5, // 5% chiều rộng màn hình
          color: color,
        ),
        SizedBox(
            width: AppSizes.blockSizeHorizontal * 1), // 1% chiều rộng màn hình
        Text(
          label,
          style: TextStyle(
              fontSize: AppSizes.blockSizeHorizontal *
                  3.5), // 3.5% chiều rộng màn hình
        ),
      ],
    );
  }

  Widget _buildSeatMap() {
    double seatWidth = AppSizes.blockSizeHorizontal * 6;
    double seatHeight = AppSizes.blockSizeHorizontal * 6;
    double seatMargin = AppSizes.blockSizeHorizontal * 1;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Cho phép cuộn ngang nếu bị tràn
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical, // Cho phép cuộn dọc nếu bị tràn
        child: Column(
          children: List.generate(rows, (row) {
            return Row(
              mainAxisSize: MainAxisSize.min, // Đảm bảo không làm tràn Row
              children: List.generate(cols, (col) {
                String seatLabel = "${String.fromCharCode(65 + row)}${col + 1}";
                bool isBooked = bookedSeats.contains(seatLabel);
                bool isSelected = selectedSeats.contains(seatLabel);

                return GestureDetector(
                  onTap:
                      isBooked ? null : () => _toggleSeatSelection(seatLabel),
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
                          fontSize: AppSizes.blockSizeHorizontal * 3),
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }

  void _toggleSeatSelection(String seatLabel) {
    setState(() {
      if (selectedSeats.contains(seatLabel)) {
        selectedSeats.remove(seatLabel);
      } else {
        selectedSeats.add(seatLabel);
      }
    });
  }

  Widget _buildBottomNavBar() {
    int ticketPrice = widget.schedule["gia_ve"] ?? 0;
    int totalPrice = selectedSeats.length * ticketPrice;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal:
              AppSizes.blockSizeHorizontal * 5, // 5% chiều rộng màn hình
          vertical: AppSizes.blockSizeVertical * 2), // 2% chiều cao màn hình
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
                    fontSize: AppSizes.blockSizeHorizontal *
                        4, // 4% chiều rộng màn hình
                    fontWeight: FontWeight.bold),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Tổng: ",
                      style: TextStyle(
                        color: Colors.black, // Chữ "Tổng" màu đen
                        fontSize: AppSizes.blockSizeHorizontal *
                            4, // 4% chiều rộng màn hình
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: "${totalPrice.toStringAsFixed(0)}đ",
                      style: TextStyle(
                        color: Colors.red, // Số tiền màu đỏ
                        fontSize: AppSizes.blockSizeHorizontal *
                            4, // 4% chiều rộng màn hình
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
              height: AppSizes.blockSizeVertical * 1), // 1% chiều cao màn hình
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Số ghế đã chọn: ${selectedSeats.length}",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: AppSizes.blockSizeHorizontal *
                        3.5), // 3.5% chiều rộng màn hình
              ),
              ElevatedButton(
                onPressed: selectedSeats.isEmpty ? null : _bookTickets,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffb20710)),
                child: Text(
                  "Đặt vé",
                  style: TextStyle(
                      fontSize: AppSizes.blockSizeHorizontal *
                          4, // 4% chiều rộng màn hình
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

  void _bookTickets() {
    if (selectedSeats.isEmpty) return;
    int totalPrice =
        (selectedSeats.length * (widget.schedule["gia_ve"] ?? 0)).toInt();
    print("Danh sách ghế đã chọn trước khi chuyển màn hình: $selectedSeats");
    List<String> selectedSeatsList = selectedSeats.toList();
  Map<String, dynamic> selectedMovie = {
    "ten_phim": widget.schedule["id_phim"]?["ten_phim"] ?? "Tên phim",
    "thoi_luong": widget.schedule["id_phim"]?["thoi_luong"] ?? 0,
    "gio_chieu": widget.schedule["ngay_gio"] ?? "Không rõ",
  };
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComboSelectionScreen(
          // selectedSeats: selectedSeats,
          selectedSeats: List<String>.from(selectedSeatsList),
          totalPrice: totalPrice,
          selectedMovie: selectedMovie,
        ),
      ),
    );
    setState(() {
      bookedSeats.addAll(selectedSeats);
      selectedSeats.clear();
    });
  }
}
