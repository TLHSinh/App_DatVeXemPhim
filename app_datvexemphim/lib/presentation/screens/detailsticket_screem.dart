import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailsTicket extends StatelessWidget {
  final List<String> selectedSeats;
  final int totalPrice;
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
    required selectedShowtime,
  }) : super(key: key);

  String formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }

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

  @override
  Widget build(BuildContext context) {
    String cinema = selectedMovie["ten_rap"] ?? "Không rõ rạp";
    String movieTitle = selectedMovie["ten_phim"] ?? "Không có tên";
    String format = selectedMovie['dinh_dang'] ?? "2D Phụ Đề";
    String showtimeDate = formatShowtime(selectedMovie['thoi_gian_chieu']);

    String imageBaseUrl = "https://rapchieuphim.com";
    String fullImageUrl = imageBaseUrl + (selectedMovie["url_poster"] ?? "");

    return Scaffold(
      appBar: AppBar(title: const Text("Thông tin thanh toán")),
      backgroundColor: const Color(0xfff9f9f9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xffffe0e0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info, color: Colors.pink),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text(
                          "Vé đã mua không thể hoàn, huỷ, đổi. Vui lòng kiểm tra kỹ thông tin!"))
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2))
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
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(movieTitle,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(format,
                            style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold)),
                        Text("Thời gian: $showtimeDate",
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
            if (selectedFoods.isNotEmpty) ...[
              const Text("Combo bắp nước",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...selectedFoods.entries.map((entry) {
                var food = foods.firstWhere((f) => f["_id"] == entry.key,
                    orElse: () => {});
                if (food.isEmpty) return const SizedBox();
                return ListTile(
                  leading: Image.network(
                      food["url_hinh"] ??
                          "https://example.com/default_food.jpg",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover),
                  title: Text(food["ten_do_an"] ?? "Chưa xác định"),
                  subtitle:
                      Text(formatCurrency((food["gia"] ?? 0) * entry.value)),
                  trailing: Text("x${entry.value}"),
                );
              }).toList(),
              const Divider(),
            ],
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 5)]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tạm tính",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(formatCurrency(totalPrice),
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
    );
  }
}
