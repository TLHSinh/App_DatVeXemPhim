import 'package:flutter/material.dart';

class SelectSeatScreen extends StatelessWidget {
  final Map<String, dynamic> showtime;

  const SelectSeatScreen({Key? key, required this.showtime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chọn Ghế"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          "Suất chiếu: ${showtime["gio_chieu"]}\nRạp: ${showtime["ten_rap"]}",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
