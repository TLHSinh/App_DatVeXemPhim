import 'package:app_datvexemphim/api/api_service.dart';
import 'package:app_datvexemphim/presentation/screens/detailsticket_screem.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ComboSelectionScreen extends StatefulWidget {
  final List<String> selectedSeats;
  final int totalPrice;
  final Map<String, dynamic> selectedMovie;

  const ComboSelectionScreen({
    super.key,
    required this.selectedSeats,
    required this.totalPrice,
    required this.selectedMovie, required Map<String, dynamic> schedule,
  });

  @override
  _ComboSelectionScreenState createState() => _ComboSelectionScreenState();
}

class _ComboSelectionScreenState extends State<ComboSelectionScreen> {
  List<dynamic> foods = [];
  Map<String, int> selectedFoods = {};

  @override
  void initState() {
    super.initState();
    fetchFoods();
    print("Danh sách ghế nhận được: ${widget.selectedSeats}");
  }

  Future<void> fetchFoods() async {
    try {
      final response = await ApiService.get("/foods");
      if (response?.statusCode == 200) {
        setState(() {
          foods = response?.data;
        });
      }
    } catch (e) {
      print("Lỗi khi tải danh sách bắp nước: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe6e6e6),
      appBar: AppBar(
          backgroundColor: Colors.white, title: const Text("Chọn Bắp Nước")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: foods.length,
              itemBuilder: (context, index) => _buildFoodCard(foods[index]),
            ),
          ),
          _buildBottomNavBar(),
        ],
      ),
    );
  }

  /// 🪑 Hiển thị số ghế đã chọn
  Widget _buildSeatInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.event_seat, color: Colors.black, size: 20),
          const SizedBox(width: 8),
          Text(
            "Ghế đã đặt: ${widget.selectedSeats.length} ghế (${widget.selectedSeats.join(", ")})",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String formatCurrency(int amount) {
    return NumberFormat("#,###", "vi_VN").format(amount);
  }

  /// 🍿 Hiển thị danh sách bắp nước đã chọn trong BottomNavBar
  Widget _buildBottomNavBar() {
    int totalPrice = _calculateTotalPrice();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hiển thị danh sách bắp nước đã chọn
          if (selectedFoods.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(height: 8),
                SizedBox(
                  height: 70, // Giới hạn chiều cao
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedFoods.length,
                    itemBuilder: (context, index) {
                      var entry = selectedFoods.entries.elementAt(index);
                      var food = foods.firstWhere((f) => f["_id"] == entry.key,
                          orElse: () => {});
                      if (food.isEmpty) return const SizedBox();
                      return _buildSelectedFoodItem(food, entry.value);
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          Row(
            children: [
              const Icon(Icons.event_seat, color: Colors.black, size: 20),
              const SizedBox(width: 8),
              Text(
                "Ghế đã đặt: ${widget.selectedSeats.length} ghế ",
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Hiển thị tổng tiền và nút thanh toán
          Text(
            "Tổng tiền: ${formatCurrency(totalPrice)}đ",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsTicket(
                    selectedSeats: widget.selectedSeats,
                    totalPrice: totalPrice,
                    selectedFoods: selectedFoods,
                    foods: foods,
                    selectedMovie: widget.selectedMovie,
                    movieId: widget.selectedMovie["_id"] ??
                        "", // Thêm ID phim nếu cần
                    selectedShowtime:
                        widget.selectedMovie["thoi_gian_chieu"] ?? "Chưa có",
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffb81d24),
                minimumSize: const Size(double.infinity, 50)),
            child: const Text("Tiếp theo",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// 📸 Hiển thị từng item bắp nước đã chọn
  Widget _buildSelectedFoodItem(Map<String, dynamic> food, int quantity) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              food["url_hinh"],
              height: 50,
              width: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.network(
                  "https://via.placeholder.com/50",
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${quantity}x ${food["ten_do_an"]}",
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedFoods.remove(food["_id"]);
              });
            },
            child: const Icon(Icons.close, color: Colors.grey, size: 18),
          ),
        ],
      ),
    );
  }

  int _calculateTotalPrice() {
    int total = widget.totalPrice;
    selectedFoods.forEach((foodId, quantity) {
      var food =
          foods.firstWhere((food) => food["_id"] == foodId, orElse: () => {});
      if (food.isNotEmpty) {
        total += ((food["gia"] as num?)?.toInt() ?? 0) * quantity;
      }
    });
    return total;
  }

  /// 🍔 Tạo danh sách bắp nước có thể chọn
  Widget _buildFoodCard(Map<String, dynamic> food) {
    String foodId = food["_id"];
    int quantity = selectedFoods[foodId] ?? 0;

    return Card(
      color: Colors.grey[200],
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Image.network(food["url_hinh"],
            width: 60, height: 60, fit: BoxFit.cover),
        title: Text(food["ten_do_an"]),
        subtitle: Text("${food["gia"].toStringAsFixed(0)}đ"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    if (quantity > 0) selectedFoods[foodId] = quantity - 1;
                  });
                }),
            Text(quantity.toString()),
            IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    selectedFoods[foodId] = quantity + 1;
                  });
                }),
          ],
        ),
      ),
    );
  }
}
