import 'package:app_datvexemphim/data/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:app_datvexemphim/api/api_service.dart';
import 'package:intl/intl.dart';
import 'package:app_datvexemphim/presentation/screens/detailticketuser_screen.dart';
import 'package:flutter/services.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> tickets = [];
  bool isLoading = true;
  String? userId;

  late TabController _tabController;
  final List<String> _tabs = ["Tất cả", "Đã đặt", "Đã hủy"];

  final String imageBaseUrl = "https://rapchieuphim.com";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    _fetchTickets();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      return;
    }
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    setState(() {
      isLoading = true;
    });

    userId = await StorageService.getUserId();
    if (userId != null) {
      try {
        final response = await _getTicketsBasedOnTab();
        if (response?.statusCode == 200) {
          setState(() {
            tickets = response?.data ?? [];
            isLoading = false;
          });
        } else {
          setState(() {
            tickets = [];
            isLoading = false;
          });
        }
      } catch (e) {
        print("❌ Lỗi khi lấy danh sách vé: $e");
        setState(() {
          tickets = [];
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<dynamic> _getTicketsBasedOnTab() async {
    int currentTab = _tabController.index;

    // Tab 0: Tất cả
    if (currentTab == 0) {
      return await ApiService.get("/ticket/listticketStatus/$userId");
    }
    // Tab 1: Đã thanh toán
    else if (currentTab == 1) {
      return await ApiService.get(
          "/ticket/listticketStatus/$userId?status=đã thanh toán");
    }
    // Tab 2: Đã hủy
    else {
      return await ApiService.get(
          "/ticket/listticketStatus/$userId?status=đã hủy");
    }
  }

  Future<void> _updateReminderStatus(String ticketId, bool value) async {
    try {
      final response = await ApiService.put(
        "/book/updateDonDatVe/$ticketId",
        {
          "nhac_nho": value,
        },
      );
      if (response?.statusCode == 200) {
        setState(() {
          _fetchTickets(); // làm mới vé
        });
      }
    } catch (e) {
      print("❌ Cập nhật nhắc nhở thất bại: $e");
      // Hiển thị thông báo lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể cập nhật trạng thái nhắc nhở'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.1,
              left: 20,
              right: 20,
            ),
          ),
        );
      }
    }
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return "Chưa có lịch chiếu";
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final vietnameseDateFormat = DateFormat('dd/MM/yyyy');
      String formattedDate = vietnameseDateFormat.format(dateTime);
      String formattedTime = DateFormat('HH:mm').format(dateTime);

      // Tính giờ kết thúc (giả sử phim dài 120 phút)
      String endTime = _calculateEndTime(formattedTime, 120);

      return "$formattedDate · $formattedTime - $endTime";
    } catch (e) {
      return "Chưa có lịch chiếu";
    }
  }

  String _calculateEndTime(String startTime, int durationMinutes) {
    try {
      List<String> parts = startTime.split(':');
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);

      int totalMinutes = hours * 60 + minutes + durationMinutes;
      int endHours = (totalMinutes ~/ 60) % 24;
      int endMinutes = totalMinutes % 60;

      return "${endHours.toString().padLeft(2, '0')}:${endMinutes.toString().padLeft(2, '0')}";
    } catch (e) {
      return startTime;
    }
  }

  void _navigateToTicketDetail(dynamic ticket) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsTicketScreen(
          ticketData: ticket,
        ),
      ),
    ).then((_) {
      if (mounted) {
        _fetchTickets();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    final Size screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.width > 600;

    // Điều chỉnh chiều cao header cho các thiết bị khác nhau
    final double headerHeight = screenSize.height * 0.08;
    final double tabBarHeight = isTablet ? 60.0 : 50.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(headerHeight),
          child: AppBar(
            title: Text(
              "Vé Của Tôi",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 22 : 20,
                color: Colors.black87,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildFilterTabs(tabBarHeight, isTablet),
              Expanded(
                child: RefreshIndicator(
                  color: Colors.red,
                  onRefresh: _fetchTickets,
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        )
                      : tickets.isEmpty
                          ? _buildEmptyState(isTablet)
                          : _buildTicketList(isTablet),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(double height, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(16, 8, 16, isTablet ? 24 : 20),
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: _tabs.map((String tab) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? 16 : 12,
                  ),
                  child: Text(
                    tab,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                );
              }).toList(),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[700],
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 16 : 14,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: isTablet ? 16 : 14,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              splashBorderRadius: BorderRadius.circular(25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketList(bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Sử dụng GridView cho máy tính bảng và màn hình lớn ở chế độ ngang
        if (isTablet &&
            MediaQuery.of(context).orientation == Orientation.landscape) {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth > 1200 ? 3 : 2,
              childAspectRatio: 1.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final showtimeData = ticket["id_lich_chieu"] ?? {};
              final movieData = showtimeData["id_phim"] ?? {};
              final showtime = showtimeData["thoi_gian_chieu"];
              final cinemaName =
                  showtimeData["id_rap"]?["ten_rap"] ?? "Rạp không xác định";
              final roomName = showtimeData["id_phong"]?["ten_phong"] ??
                  "Phòng không xác định";

              return AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 300 + (index * 100)),
                child: _buildTicketCard(ticket, movieData, showtime, cinemaName,
                    roomName, isTablet),
              );
            },
          );
        } else {
          // ListView cho điện thoại và máy tính bảng ở chế độ dọc
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final showtimeData = ticket["id_lich_chieu"] ?? {};
              final movieData = showtimeData["id_phim"] ?? {};
              final showtime = showtimeData["thoi_gian_chieu"];
              final cinemaName =
                  showtimeData["id_rap"]?["ten_rap"] ?? "Rạp không xác định";
              final roomName = showtimeData["id_phong"]?["ten_phong"] ??
                  "Phòng không xác định";

              return AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 300 + (index * 100)),
                child: _buildTicketCard(ticket, movieData, showtime, cinemaName,
                    roomName, isTablet),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildTicketCard(dynamic ticket, Map<String, dynamic> movieData,
      String? showtime, String cinemaName, String roomName, bool isTablet) {
    // Điều chỉnh kích thước poster theo thiết bị
    final double posterWidth = isTablet ? 100 : 90;
    final double posterHeight = isTablet ? 140 : 120;

    // Font size thông tin
    final double titleFontSize = isTablet ? 16 : 15;
    final double infoFontSize = isTablet ? 13 : 12;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _navigateToTicketDetail(ticket),
            splashColor: Colors.red.withOpacity(0.1),
            highlightColor: Colors.red.withOpacity(0.05),
            child: Column(
              children: [
                _buildTicketHeader(showtime, ticket["trang_thai"], isTablet),
                Padding(
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMoviePoster(movieData, posterWidth, posterHeight),
                      SizedBox(width: isTablet ? 20 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMovieTitle(movieData, titleFontSize),
                            SizedBox(height: isTablet ? 10 : 8),
                            _buildCinemaInfo(
                                cinemaName, roomName, infoFontSize),
                            SizedBox(height: isTablet ? 14 : 12),
                            _buildShowtimeInfo(
                                showtime, infoFontSize, isTablet),
                            SizedBox(height: isTablet ? 10 : 8),
                            _buildSeatInfo(
                                ticket["danh_sach_ghe"] ?? [], infoFontSize),
                            SizedBox(height: isTablet ? 14 : 12),
                            _buildNotificationRow(ticket, infoFontSize),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketHeader(String? showtime, String? status, bool isTablet) {
    bool isComingSoon = false;
    if (showtime != null) {
      try {
        final showDateTime = DateTime.parse(showtime);
        final now = DateTime.now();
        final diff = showDateTime.difference(now);
        if (diff.inMinutes > 0 && diff.inHours <= 24) {
          isComingSoon = true;
        }
      } catch (_) {}
    }

    // Xác định màu nền của header dựa trên trạng thái
    Color headerColor;
    String headerTitle;
    IconData headerIcon;

    if (isComingSoon) {
      headerColor = Colors.orange;
      headerTitle = "Sắp chiếu";
      headerIcon = Icons.access_time;
    } else {
      switch (status?.toLowerCase()) {
        case "đã thanh toán":
          headerColor = Colors.green[700]!;
          headerTitle = "Đã thanh toán";
          headerIcon = Icons.check_circle;
          break;
        case "đã sử dụng":
          headerColor = Colors.blue[700]!;
          headerTitle = "Đã sử dụng";
          headerIcon = Icons.movie;
          break;
        case "đã hủy":
          headerColor = Colors.red[700]!;
          headerTitle = "Đã hủy";
          headerIcon = Icons.cancel;
          break;
        default:
          headerColor = Colors.grey[700]!;
          headerTitle = "Đang xử lý";
          headerIcon = Icons.help_outline;
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: headerColor.withOpacity(0.15),
        border: Border(
          bottom: BorderSide(
            color: headerColor.withOpacity(0.2),
            width: 1.0,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16, vertical: isTablet ? 12 : 10),
      child: Row(
        children: [
          Icon(
            headerIcon,
            size: isTablet ? 18 : 16,
            color: headerColor,
          ),
          SizedBox(width: isTablet ? 8 : 6),
          Text(
            headerTitle,
            style: TextStyle(
              color: headerColor,
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 15 : 13,
            ),
          ),
          const Spacer(),
          Text(
            "Chi tiết",
            style: TextStyle(
              color: headerColor.withOpacity(0.7),
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: isTablet ? 6 : 4),
          Icon(
            Icons.arrow_forward_ios,
            size: isTablet ? 16 : 14,
            color: headerColor.withOpacity(0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildMoviePoster(
      Map<String, dynamic> movieData, double width, double height) {
    String posterUrl = movieData["url_poster"] != null
        ? imageBaseUrl + movieData["url_poster"].toString()
        : "https://via.placeholder.com/300";

    return Hero(
      tag: 'poster_${movieData["_id"] ?? "unknown"}',
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            posterUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.movie, color: Colors.grey[400], size: width * 0.4),
                  const SizedBox(height: 8),
                  Text(
                    "Không có ảnh",
                    style: TextStyle(
                      fontSize: width * 0.11,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    strokeWidth: 2,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMovieTitle(Map<String, dynamic> movieData, double fontSize) {
    return Text(
      (movieData["ten_phim"]?.toString() ?? "Phim không xác định")
          .toUpperCase(),
      style: TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: fontSize,
        letterSpacing: 0.5,
        height: 1.3,
        color: Colors.black87,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCinemaInfo(String cinemaName, String roomName, double fontSize) {
    return Row(
      children: [
        Icon(Icons.location_on, size: fontSize + 2, color: Colors.red[400]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            "$cinemaName · $roomName",
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildShowtimeInfo(String? showtime, double fontSize, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 14 : 12, vertical: isTablet ? 10 : 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today,
              size: fontSize + 2, color: Colors.red[400]),
          SizedBox(width: isTablet ? 10 : 8),
          Expanded(
            child: Text(
              _formatDateTime(showtime),
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatInfo(List<dynamic> seats, double fontSize) {
    if (seats.isEmpty) {
      return Container();
    }

    // Tạo danh sách ghế
    List<String> seatNumbers = [];
    for (var seat in seats) {
      if (seat["so_ghe"] != null) {
        seatNumbers.add(seat["so_ghe"]);
      }
    }

    if (seatNumbers.isEmpty) {
      return Container();
    }

    return Row(
      children: [
        Icon(Icons.chair, size: fontSize + 2, color: Colors.red[400]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            "Ghế: ${seatNumbers.join(', ')}",
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationRow(dynamic ticket, double fontSize) {
    bool reminderOn = ticket["nhac_nho"] == true;
    bool canRemind = ticket["trang_thai"]?.toLowerCase() == "đã thanh toán";

    // Nếu không phải là vé đã thanh toán, không cho phép bật nhắc nhở
    if (!canRemind) {
      return Container();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  size: fontSize + 4,
                  color: reminderOn ? Colors.red : Colors.grey[400],
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    "Nhắc nhở trước 30 phút",
                    style: TextStyle(
                      fontSize: fontSize,
                      color: reminderOn ? Colors.red : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: fontSize / 15, // Điều chỉnh scale theo font size
            child: Switch(
              value: reminderOn,
              onChanged: canRemind
                  ? (value) {
                      _updateReminderStatus(ticket["_id"], value);
                    }
                  : null,
              activeColor: Colors.red,
              activeTrackColor: Colors.red.withOpacity(0.3),
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[300],
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    double iconSize = isTablet ? 80 : 60;
    double headingSize = isTablet ? 24 : 22;
    double textSize = isTablet ? 16 : 14;
    double buttonPadding = isTablet ? 18 : 14;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isTablet ? 160 : 120,
                height: isTablet ? 160 : 120,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Colors.red.withOpacity(0.1), Colors.white],
                    radius: 0.8,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.confirmation_number_outlined,
                  size: iconSize,
                  color: Colors.red.withOpacity(0.7),
                ),
              ),
              SizedBox(height: isTablet ? 32 : 24),
              Text(
                "Chưa có vé nào",
                style: TextStyle(
                  fontSize: headingSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: isTablet ? 16 : 12),
              Text(
                "Hãy khám phá các bộ phim mới nhất và đặt vé ngay!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: textSize,
                  color: Colors.grey[500],
                  height: 1.5,
                ),
              ),
              SizedBox(height: isTablet ? 40 : 32),
              // ElevatedButton.icon(
              //   icon: Icon(Icons.local_movies, size: isTablet ? 22 : 20),
              //   label: Text("Xem phim đang chiếu",
              //       style: TextStyle(fontSize: isTablet ? 16 : 14)),
              //   onPressed: () {
              //     // Điều hướng đến trang phim đang chiếu
              //     Navigator.of(context).pop();
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.red,
              //     foregroundColor: Colors.white,
              //     elevation: 2,
              //     shadowColor: Colors.red.withOpacity(0.4),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(30),
              //     ),
              //     padding: EdgeInsets.symmetric(
              //         horizontal: isTablet ? 40 : 32, vertical: buttonPadding),
              //   ),
              // ),
              SizedBox(height: isTablet ? 20 : 16),
              TextButton.icon(
                icon: Icon(Icons.refresh,
                    size: isTablet ? 20 : 18, color: Colors.red[400]),
                label: Text("Tải lại",
                    style: TextStyle(
                        color: Colors.red[400], fontSize: isTablet ? 16 : 14)),
                onPressed: _fetchTickets,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
