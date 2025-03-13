import 'package:app_datvexemphim/presentation/screens/pickmovieandtime_screen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:app_datvexemphim/api/api_service.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  List<dynamic> cinemas = []; // Danh sách rạp
  List<dynamic> filteredCinemas = []; // Danh sách rạp đã lọc
  List<String> provinces = []; // Danh sách tỉnh/thành
  String? selectedProvince; // Tỉnh/thành được chọn
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProvinces();
    fetchCinemas();
  }

  // Gọi API lấy danh sách tỉnh/thành từ nguồn công khai
  Future<void> fetchProvinces() async {
    try {
      Response response =
          await Dio().get("https://provinces.open-api.vn/api/?depth=1");
      if (response.statusCode == 200) {
        setState(() {
          provinces =
              response.data.map<String>((p) => p["name"].toString()).toList();
        });
      }
    } catch (e) {
      print("❌ Lỗi khi lấy danh sách tỉnh/thành: $e");
    }
  }

  // Gọi API lấy danh sách rạp từ backend
  Future<void> fetchCinemas() async {
    Response? response = await ApiService.get("/rapphims");
    if (response != null && response.statusCode == 200) {
      setState(() {
        cinemas = response.data;
        filteredCinemas = cinemas; // Mặc định hiển thị tất cả rạp
        isLoading = false;
      });
    }
  }

  // Lọc rạp theo tỉnh/thành được chọn
  void filterCinemas(String province) {
    setState(() {
      selectedProvince = province;
      filteredCinemas = cinemas.where((cinema) {
        String diaChi = cinema["dia_chi"] ?? ""; // Kiểm tra null
        return diaChi.contains(province);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      appBar: AppBar(
        title: const Text("Danh Sách Rạp"),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Hiển thị vòng xoay khi tải
          : Column(
              children: [
                // Dropdown chọn tỉnh/thành
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Chọn tỉnh/thành",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    value: selectedProvince,
                    items: provinces.map((String province) {
                      return DropdownMenuItem<String>(
                        value: province,
                        child: Text(province),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        filterCinemas(value);
                      }
                    },
                  ),
                ),

                // Danh sách rạp
                Expanded(
                  child: filteredCinemas.isEmpty
                      ? const Center(
                          child: Text(
                            "Không có rạp nào trong tỉnh/thành này",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredCinemas.length,
                          itemBuilder: (context, index) {
                            var cinema = filteredCinemas[index];
                            return CinemaCard(cinema: cinema);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class CinemaCard extends StatelessWidget {
  final Map<String, dynamic> cinema;

  const CinemaCard({Key? key, required this.cinema}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageBaseUrl = "https://rapchieuphim.com";
    String fullImageUrl = imageBaseUrl + (cinema["anh"] ?? "");

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PickMovieAndTimeScreen(cinema: cinema),
          ),
        );
      },
      child: Card(
        color: Colors.grey[200], // Màu trắng xám
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 4, // Thêm bóng đổ
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh rạp
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                fullImageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    "https://via.placeholder.com/300",
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),

            // Thông tin rạp
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên rạp
                  Text(
                    cinema["ten_rap"] ?? "Không có tên",
                    style: const TextStyle(
                      color: Colors.black, // Màu chữ đen
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Địa chỉ
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.redAccent, size: 20),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          cinema["dia_chi"] ?? "Không có địa chỉ",
                          style: const TextStyle(
                              color: Colors.black87, fontSize: 14), // Màu chữ đen
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Số điện thoại
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.green, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        cinema["so_dien_thoai"] ?? "Không có SĐT",
                        style:
                            const TextStyle(color: Colors.black87, fontSize: 14), // Màu chữ đen
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}