import 'package:app_datvexemphim/presentation/screens/pickmovieandtime_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:app_datvexemphim/api/api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

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
  bool isShowingNearest =
      false; // Biến để kiểm tra xem đang hiển thị rạp gần nhất hay không

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
      isShowingNearest = true;
      selectedProvince = null; // Reset tỉnh/thành được chọn
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

  // Hiển thị tất cả rạp
  void showAllCinemas() {
    setState(() {
      filteredCinemas = cinemas;
      isShowingNearest = false;
      selectedProvince = null; // Reset tỉnh/thành được chọn
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
        "✅ Đã lấy vị trí hiện tại: (${position.latitude}, ${position.longitude})");

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
        title: const Text('Danh Sách Rạp',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xfff9f9f9),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Hiển thị vòng xoay khi tải
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Hàng chứa hai nút - Danh sách rạp và 5 rạp gần nhất
                      Row(
                        children: [
                          // Nút Danh sách rạp
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.movie),
                              label: const Text("Danh sách rạp"),
                              onPressed: showAllCinemas,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isShowingNearest
                                    ? Colors.grey[300]
                                    : Color(0xffb81d24),
                                foregroundColor: isShowingNearest
                                    ? Colors.black
                                    : Colors.white,
                                elevation: 2,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Nút 5 rạp gần nhất
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.near_me),
                              label: const Text("Các rạp gần đây"),
                              onPressed: isLocationLoading
                                  ? null
                                  : _getCurrentLocation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isShowingNearest
                                    ? Color(0xffb81d24)
                                    : Colors.grey[300],
                                foregroundColor: isShowingNearest
                                    ? Colors.white
                                    : Colors.black,
                                elevation: 2,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Dropdown chọn tỉnh/thành
                      if (!isShowingNearest) // Chỉ hiển thị dropdown khi không đang xem 5 rạp gần nhất
                        DropdownButton2<String>(
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    ],
                  ),
                ),

                // Trạng thái đang tải vị trí
                if (isLocationLoading)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text("Đang tìm vị trí của bạn...",
                            style: TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),

                // Tiêu đề của danh sách hiển thị
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        isShowingNearest ? Icons.near_me : Icons.movie_filter,
                        color: Color(0xffEE0033),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isShowingNearest
                            ? "5 rạp gần vị trí của bạn"
                            : selectedProvince != null
                                ? "Rạp tại $selectedProvince"
                                : "Tất cả rạp phim",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffEE0033),
                        ),
                      ),
                    ],
                  ),
                ),

                // Danh sách rạp
                Expanded(
                  child: filteredCinemas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.movie,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isShowingNearest
                                    ? "Không tìm thấy rạp nào gần bạn"
                                    : "Không có rạp nào trong khu vực này",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredCinemas.length + 1,
                          itemBuilder: (context, index) {
                            if (index == filteredCinemas.length) {
                              return const SizedBox(height: 50);
                            }
                            var cinema = filteredCinemas[index];
                            return CinemaCard(
                              cinema: cinema,
                              onNavigate: () {
                                _openMaps(
                                    cinema["geo_lat"], cinema["geo_long"]);
                              },
                            );
                          },
                        ),
                )
              ],
            ),
    );
  }
}

class CinemaCard extends StatelessWidget {
  final Map<String, dynamic> cinema;
  final VoidCallback onNavigate;

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
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh rạp với overlay gradient
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    fullImageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 160,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.movie,
                          size: 60,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
                // Gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Tên rạp phim trên hình ảnh
                Positioned(
                  bottom: 8,
                  left: 12,
                  right: 12,
                  child: Text(
                    cinema["ten_rap"] ?? "Không có tên",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Color.fromARGB(150, 0, 0, 0),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Thông tin rạp
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Địa chỉ
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on,
                          color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cinema["dia_chi"] ?? "Không có địa chỉ",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Số điện thoại
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.green[600], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        cinema["so_dien_thoai"] ?? "Không có SĐT",
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Các nút tùy chọn
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nút Xem phim
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.movie_filter, size: 16),
                          label: const Text("Xem phim"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PickMovieAndTimeScreen(cinema: cinema),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffEE0033),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            textStyle: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Nút Chỉ đường
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(LineAwesome.directions_solid,
                              size: 16),
                          label: const Text("Chỉ đường"),
                          onPressed: onNavigate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            textStyle: const TextStyle(fontSize: 13),
                          ),
                        ),
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
