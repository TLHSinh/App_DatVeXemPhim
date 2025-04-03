import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_datvexemphim/api/api_service.dart';
import 'package:intl/intl.dart';

class GiftScreen extends StatefulWidget {
  const GiftScreen({super.key});

  @override
  _GiftScreenState createState() => _GiftScreenState();
}

class _GiftScreenState extends State<GiftScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Ưu đãi & Voucher',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          indicatorColor: Colors.redAccent,
          tabs: const [
            Tab(text: "Ưu đãi"),
            Tab(text: "Voucher"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AdsTab(),
          VouchersTab(),
        ],
      ),
    );
  }
}

class AdsTab extends StatefulWidget {
  const AdsTab({super.key});

  @override
  _AdsTabState createState() => _AdsTabState();
}

class _AdsTabState extends State<AdsTab> with AutomaticKeepAliveClientMixin {
  List<dynamic> _promotions = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    fetchPromotions();
  }

  Future<void> fetchPromotions() async {
    try {
      final response = await ApiService.get("/admin/ads");
      if (response != null && response.statusCode == 200) {
        var adsJson = response.data; // Với Dio, response.body -> response.data
        setState(() {
          _promotions = adsJson is List
              ? adsJson.where((ad) => ad['loai_qc'] == 'banner').toList()
              : [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(String date) {
    try {
      DateTime dateTime =
          DateTime.parse(date); // Chuyển đổi chuỗi ngày thành DateTime
      return DateFormat('dd/MM/yyyy').format(dateTime); // Định dạng lại ngày
    } catch (e) {
      return date; // Nếu có lỗi, trả về chuỗi gốc
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: 80.0), // Tránh bị che bởi thanh điều hướng
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _promotions.isEmpty
                ? Center(child: Text("Không có ưu đãi."))
                : ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemCount: _promotions.length,
                    itemBuilder: (context, index) {
                      var ad = _promotions[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              imageUrl: ad['url_hinh'],
                              title: ad['tieu_de'],
                              description: ad['mo_ta'],
                            ),
                          ),
                        ),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                // Hình ảnh quảng cáo
                                Image.network(
                                  ad['url_hinh'],
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                        "assets/images/placeholder.jpg",
                                        fit: BoxFit.cover);
                                  },
                                ),
                                // Overlay để hiển thị nội dung
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.7),
                                          Colors.transparent
                                        ],
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ad['tieu_de'] ?? "Không có tiêu đề",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          ad['mo_ta'] ?? "Không có mô tả",
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          _formatDate(ad['ngay_bat_dau']) +
                                              " - " +
                                              _formatDate(ad['ngay_ket_thuc']),
                                          style: TextStyle(
                                            color: Colors.white60,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class VouchersTab extends StatefulWidget {
  const VouchersTab({super.key});

  @override
  _VouchersTabState createState() => _VouchersTabState();
}

class _VouchersTabState extends State<VouchersTab>
    with AutomaticKeepAliveClientMixin {
  List<dynamic> _vouchers = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    fetchVouchers();
  }

  Future<void> fetchVouchers() async {
    try {
      final response = await ApiService.get("/admin/vouchers");
      if (response != null && response.statusCode == 200) {
        var vouchersJson = response.data; // Với Dio, dùng response.data
        setState(() {
          _vouchers =
              (vouchersJson['success'] == true && vouchersJson['data'] is List)
                  ? vouchersJson['data']
                  : [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: 80.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _vouchers.isEmpty
                ? Center(child: Text("Không có voucher."))
                : ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemCount: _vouchers.length,
                    itemBuilder: (context, index) {
                      var voucher = _vouchers[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                                imageUrl: voucher['url_hinh'],
                                title: voucher['ma_voucher'],
                                description:
                                    "Giảm: ${voucher['gia_tri_giam']} VNĐ (Đơn tối thiểu: ${voucher['don_hang_toi_thieu']} VNĐ)"),
                          ),
                        ),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                // Hình ảnh voucher
                                Image.network(
                                  voucher['url_hinh'],
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                        "assets/images/placeholder.jpg",
                                        fit: BoxFit.cover);
                                  },
                                ),
                                // Overlay chứa thông tin voucher
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.7),
                                          Colors.transparent
                                        ],
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          voucher['ma_voucher'] ??
                                              "Không có mã",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          "Giảm ${voucher['gia_tri_giam']} VNĐ",
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          "Đơn tối thiểu: ${voucher['don_hang_toi_thieu']} VNĐ",
                                          style: TextStyle(
                                            color: Colors.white60,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;

  const DetailScreen({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
  });

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Lưu thành công!"),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trái
          children: [
            Image.network(imageUrl,
                width: double.infinity, fit: BoxFit.contain),
            const SizedBox(height: 16), // Khoảng cách giữa ảnh và văn bản
            Text(
              description,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.justify, // Căn đều nội dung mô tả
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color.fromARGB(255, 255, 243, 243),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => _showSuccessMessage(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Lưu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
