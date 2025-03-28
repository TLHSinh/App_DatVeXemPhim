import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      final response =
          await http.get(Uri.parse('http://localhost:5000/api/v1/admin/ads'));
      if (response.statusCode == 200) {
        var adsJson = json.decode(response.body);
        setState(() {
          _promotions = adsJson is List
              ? adsJson.where((ad) => ad['loai_qc'] == 'banner').toList()
              : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _isLoading
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
                            description: ad['mo_ta']),
                      ),
                    ),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          ad['url_hinh'],
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit
                              .cover, // Đảm bảo ảnh luôn fit vào khung, không bị méo
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset("assets/images/placeholder.jpg",
                                fit: BoxFit.cover);
                          },
                        ),
                      ),
                    ),
                  );
                },
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
      final response = await http
          .get(Uri.parse('http://localhost:5000/api/v1/admin/vouchers'));
      if (response.statusCode == 200) {
        var vouchersJson = json.decode(response.body);
        setState(() {
          _vouchers =
              (vouchersJson['success'] == true && vouchersJson['data'] is List)
                  ? vouchersJson['data']
                  : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _isLoading
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
                        child: Image.network(
                          voucher['url_hinh'],
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset("assets/images/placeholder.jpg",
                                fit: BoxFit.cover);
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
  }
}

class DetailScreen extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;

  const DetailScreen(
      {super.key,
      required this.imageUrl,
      required this.title,
      required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.network(imageUrl, width: double.infinity, fit: BoxFit.contain),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(description, style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
