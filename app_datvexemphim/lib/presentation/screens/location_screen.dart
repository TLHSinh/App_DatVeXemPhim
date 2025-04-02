import 'package:app_datvexemphim/presentation/screens/pickmovieandtime_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:app_datvexemphim/api/api_service.dart';
import 'package:geolocator/geolocator.dart'; // Thêm import này
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart'; // Thêm import này
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  List<dynamic> cinemas = []; // Danh sách rạp
  List<dynamic> filteredCinemas = []; // Danh sách rạp đã lọc
  List<String> provinces = []; // Danh sách tỉnh/thành
  String? selectedProvince; // Tỉnh/thành được chọn
  bool isLoading = true;
  bool isLocationLoading = false; // Biến để theo dõi trạng thái lấy vị trí

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

  // Tính khoảng cách giữa hai điểm
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Bán kính trái đất tính bằng km
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; // Khoảng cách tính bằng km
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  // Tìm kiếm 5 rạp gần nhất
  void findNearestCinemas(double userLat, double userLon) {
    List<dynamic> nearestCinemas = [];
    for (var cinema in cinemas) {
      double? lat = cinema["geo_lat"];
      double? lon = cinema["geo_long"];

      // Kiểm tra xem lat và lon có phải là null không
      if (lat != null && lon != null) {
        double distance = calculateDistance(
          userLat,
          userLon,
          lat,
          lon,
        );
        nearestCinemas.add({"cinema": cinema, "distance": distance});
      }
    }
    nearestCinemas.sort((a, b) => a["distance"].compareTo(b["distance"]));
    setState(() {
      filteredCinemas = nearestCinemas.take(5).map((e) => e["cinema"]).toList();
    });

    // In ra thông báo về 5 rạp gần nhất
    print("📍 Vị trí hiện tại: ($userLat, $userLon)");
    print("🎬 5 rạp gần nhất:");
    for (var cinema in filteredCinemas) {
      print("- ${cinema['ten_rap']} tại ${cinema['dia_chi']}");
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

  // Lấy vị trí hiện tại của người dùng
  Future<void> _getCurrentLocation() async {
    setState(() {
      isLocationLoading = true; // Bắt đầu quá trình lấy vị trí
    });

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Nếu quyền bị từ chối vĩnh viễn, hiển thị thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng cấp quyền vị trí")),
      );
      setState(() {
        isLocationLoading = false; // Kết thúc quá trình lấy vị trí
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    findNearestCinemas(position.latitude, position.longitude);

    // In ra thông báo đã lấy được vị trí
    print(
        "✅ Đã lấy vị trí hiện tại: ($position.latitude, $position.longitude)");

    setState(() {
      isLocationLoading = false; // Kết thúc quá trình lấy vị trí
    });
  }

  // Mở Google Maps chỉ đường đến rạp
  void _openMaps(double lat, double lon) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      appBar: AppBar(
        title: const Text(
          'Danh Sách Rạp',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xfff9f9f9),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Ô chọn tỉnh/thành (70%)
                      Expanded(
                        flex: 7,
                        child: SizedBox(
                          height: 50,
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: const Text(
                              "Chọn tỉnh/thành",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            value: (selectedProvince?.isNotEmpty ?? false)
                                ? selectedProvince
                                : null,
                            items: provinces.map((String province) {
                              return DropdownMenuItem<String>(
                                value: province,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 12),
                                  child: Text(
                                    province,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                filterCinemas(value);
                              }
                            },
                            buttonStyleData: ButtonStyleData(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              offset: const Offset(
                                  0, -10), // Đẩy dropdown xuống dưới một chút
                              maxHeight: 400,
                              padding: const EdgeInsets.only(top: 8),
                              width: MediaQuery.of(context).size.width - 32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(0, 4)),
                                ],
                              ),
                            ),
                            iconStyleData: IconStyleData(
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  size: 24, color: Colors.black54),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Nút tìm kiếm (30%)
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                isLocationLoading ? null : _getCurrentLocation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: isLocationLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  )
                                : Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.location_on,
                                            size: 18, color: Colors.white),
                                        const SizedBox(width: 6),
                                        const Text(
                                          "Gần đây",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Danh sách rạp
                Expanded(
                  child: (filteredCinemas.isEmpty)
                      ? const Center(
                          child: Text(
                            "Không có rạp nào trong tỉnh/thành này",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredCinemas.length,
                          itemBuilder: (context, index) {
                            var cinema = filteredCinemas[index];

                            // Kiểm tra dữ liệu null
                            String cinemaName =
                                cinema["name"] ?? "Rạp không tên";
                            double? lat = cinema["geo_lat"];
                            double? long = cinema["geo_long"];

                            return CinemaCard(
                              cinema: cinema,
                              onNavigate: () {
                                _openMaps(
                                    cinema["geo_lat"], cinema["geo_long"]);
                              },
                            );
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
  final VoidCallback onNavigate; // Hàm chỉ đường

  const CinemaCard({super.key, required this.cinema, required this.onNavigate});

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
        color: Colors.grey[200], // Màu nền trắng xám
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 4, // Hiệu ứng bóng đổ
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
                  // Tiêu đề và nút chỉ đường
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          cinema["ten_rap"] ?? "Không có tên",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.directions,
                            color: Colors.blueAccent),
                        onPressed: onNavigate,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Địa chỉ
                  _buildInfoRow(Icons.location_on, Colors.redAccent,
                      cinema["dia_chi"], "Không có địa chỉ"),

                  // Số điện thoại
                  _buildInfoRow(Icons.phone, Colors.green,
                      cinema["so_dien_thoai"], "Không có SĐT"),

                  const SizedBox(height: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm tạo thông tin hàng
  Widget _buildInfoRow(
      IconData icon, Color iconColor, String? value, String defaultValue) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value ?? defaultValue,
            style: const TextStyle(color: Colors.black87, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
