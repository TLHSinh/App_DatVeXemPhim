import 'package:flutter/material.dart';

class DetailsTicket extends StatelessWidget {
  final List<String> selectedSeats;
  final double totalPrice;
  final Map<String, int> selectedFoods;
  final List<dynamic> foods;
  final Map<String, dynamic> selectedMovie;

  const DetailsTicket({
    Key? key,
    required this.selectedSeats,
    required this.totalPrice,
    required this.selectedFoods,
    required this.foods,
    required this.selectedMovie,
    required String movieId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageBaseUrl = "https://rapchieuphim.com";
    String posterUrl =
        imageBaseUrl + (selectedMovie["id_phim"]?["url_poster"] ?? "");
    String movieTitle =
        selectedMovie["id_phim"]?["ten_phim"] ?? "Chưa cập nhật";
    String cinemaName = selectedMovie["ten_rap"] ?? "Rạp chưa xác định";
    String format = selectedMovie["dinh_dang"] ?? "Không rõ";
    String showTime = selectedMovie["thoi_gian"] ?? "--:--";
    String showDate = selectedMovie["ngay_chieu"] ?? "--/--/----";

    return Scaffold(
      appBar: AppBar(title: const Text("Thông tin thanh toán")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info, color: Colors.pink),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text(
                          "Bạn ơi, vé đã mua sẽ không thể hoàn, huỷ, đổi vé. Bạn nhớ kiểm tra kỹ thông tin nha!"))
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
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
                    child: Image.network(posterUrl,
                        width: 80, height: 120, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image_not_supported, size: 80);
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cinemaName,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(movieTitle,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("$format",
                            style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold)),
                        Text("Thời gian: $showTime - $showDate",
                            style: TextStyle(color: Colors.grey[700])),
                        Text("Ghế: ${selectedSeats.join(", ")}",
                            style: TextStyle(color: Colors.grey[700])),
                      ],
                    ),
                  ),
                ],
              ),
            ),




            
            const SizedBox(height: 16),
            const Text("Combo bắp nước",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...selectedFoods.entries.map((entry) {
              var food = foods.firstWhere((f) => f["_id"] == entry.key,
                  orElse: () => {});
              if (food.isEmpty) return const SizedBox();
              return ListTile(
                leading: Image.network(
                    food["url_hinh"] ?? "https://example.com/default_food.jpg",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover),
                title: Text(food["ten_do_an"] ?? "Chưa xác định"),
                subtitle: Text("${food["gia"] * entry.value}đ"),
                trailing: Text("x${entry.value}"),
              );
            }).toList(),
            const Divider(),
          ],
        ),
      ),
      bottomSheet: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Tạm tính",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("${totalPrice.toStringAsFixed(0)}đ",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffb81d24),
                        minimumSize: const Size(double.infinity, 50)),
                    child: const Text("Tiếp theo",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
