// import 'package:flutter/material.dart';

// class TicketScreen extends StatelessWidget {
//   const TicketScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Container(
//         child: Text('Coming soon...'),
//       ),
//     );
//   }
// }





import 'package:app_datvexemphim/data/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:app_datvexemphim/api/api_service.dart';


class TicketScreen extends StatefulWidget {
  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  List<dynamic> tickets = [];
  bool isLoading = true;
  String? userId;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
     userId = await StorageService.getUserId();
    if (userId != null) {
      try {
        final response = await ApiService.get("/ticket/listticket/$userId");
        if (response?.statusCode == 200) {
          setState(() {
            tickets = response?.data; // Lưu danh sách vé vào biến
            isLoading = false;
          });
        }
      } catch (e) {
        print("❌ Lỗi khi lấy danh sách vé: $e");
        setState(() {
          isLoading = false;
        });
      }
    } else {
      // Xử lý trường hợp không có userId
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh Sách Vé"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tickets.isEmpty
              ? const Center(child: Text("Không có vé nào đã đặt."))
              : ListView.builder(
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    var ticket = tickets[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("ID Vé: ${ticket["_id"]}"),
                            Text("Số ghế: ${ticket["danh_sach_ghe"].join(", ")}"),
                            Text("Tổng tiền: ${ticket["tong_tien"]}"),
                            Text("Trạng thái: ${ticket["trang_thai"]}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
