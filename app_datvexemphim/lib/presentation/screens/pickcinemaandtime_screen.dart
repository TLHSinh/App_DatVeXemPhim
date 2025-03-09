import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class PickCinemaAndTimeScreen extends StatefulWidget {
  @override
  _PickCinemaAndTimeScreenState createState() => _PickCinemaAndTimeScreenState();
}

class _PickCinemaAndTimeScreenState extends State<PickCinemaAndTimeScreen> {
  List<dynamic> cinemas = [];
  String? selectedCinema;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCinemas();
  }

  Future<void> fetchCinemas() async {
    try {
      var response = await Dio().get('http://localhost:5000/api/v1/rapphims');
      setState(() {
        cinemas = response.data;
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi lấy danh sách rạp: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chọn Rạp & Giờ')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                DropdownButton<String>(
                  hint: Text("Chọn rạp"),
                  value: selectedCinema,
                  onChanged: (value) {
                    setState(() {
                      selectedCinema = value;
                    });
                  },
                  items: cinemas.map<DropdownMenuItem<String>>((cinema) {
                    return DropdownMenuItem<String>(
                      value: cinema['_id'], // hoặc cinema['ten_rap']
                      child: Text(cinema['ten_rap']),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}
