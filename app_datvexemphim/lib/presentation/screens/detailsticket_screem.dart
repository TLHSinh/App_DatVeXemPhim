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
    required this.foods, required this.selectedMovie,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chi tiết vé")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Phim: ${selectedMovie["ten_phim"]}", style: const TextStyle(fontSize: 18)),
            Text("Ghế đã đặt: ${selectedSeats.join(", ")}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Text("Tổng tiền: ${totalPrice.toStringAsFixed(0)}đ", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            const Text("Combo đã chọn:", style: TextStyle(fontSize: 18)),
            ...selectedFoods.entries.map((entry) {
              var food = foods.firstWhere((f) => f["_id"] == entry.key, orElse: () => {});
              if (food.isEmpty) return const SizedBox();
              return Text("${entry.value}x ${food["ten_do_an"]} - ${food["gia"] * entry.value}đ");
            }).toList(),
          ],
        ),
      ),
    );
  }
}