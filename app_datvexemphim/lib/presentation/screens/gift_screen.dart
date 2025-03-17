import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GiftScreen extends StatefulWidget {
  const GiftScreen({super.key});

  @override
  _GiftScreenState createState() => _GiftScreenState();
}

class _GiftScreenState extends State<GiftScreen> with SingleTickerProviderStateMixin {
  List<dynamic> promotions = [];
  List<dynamic> vouchers = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchPromotions();
  }

  Future<void> fetchPromotions() async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/admin/ads'));
    if (response.statusCode == 200) {
      setState(() {
        List<dynamic> ads = json.decode(response.body);
        promotions = ads.where((ad) => ad['loai_qc'] == 'banner').toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quảng Cáo & Ưu Đãi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Ưu đãi"),
            Tab(text: "Voucher"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildAdsList(promotions),
          Center(child: Text("Voucher chưa có dữ liệu")),
        ],
      ),
    );
  }

  Widget buildAdsList(List<dynamic> adsList) {
    return GridView.builder(
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
      ),
      itemCount: adsList.length,
      itemBuilder: (context, index) {
        var ad = adsList[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdDetailScreen(ad: ad),
              ),
            );
          },
          child: Card(
            elevation: 4,
            child: Column(
              children: [
                Image.network(
                  ad['url_hinh'],
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    ad['tieu_de'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AdDetailScreen extends StatelessWidget {
  final Map<String, dynamic> ad;

  const AdDetailScreen({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(ad['tieu_de'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(ad['url_hinh'], width: double.infinity, height: 200, fit: BoxFit.cover),
            SizedBox(height: 10),
            Text(ad['mo_ta'], style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
