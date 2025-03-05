import 'package:flutter/material.dart';

class PickCinemaAndTime extends StatelessWidget {
    final Map<String, dynamic> movie;
  const PickCinemaAndTime({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Giao diện chọn rạp và giờ'),);
  }
}