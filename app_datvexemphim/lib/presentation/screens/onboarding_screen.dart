import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/onboarding1.png",
      "title": "Chào mừng bạn đến với ATSH!",
      "description": "Khám phá hàng ngàn bộ phim hấp dẫn ngay hôm nay.",
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Tìm kiếm nhanh chóng",
      "description": "Tìm kiếm bộ phim yêu thích chỉ trong vài giây.",
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": "Xem phim mọi lúc mọi nơi",
      "description":
          "Thưởng thức phim trên mọi thiết bị với trải nghiệm mượt mà.",
    }
  ];

  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } else {
      _goToHome();
    }
  }

  void _goToHome() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      appBar: AppBar(
        backgroundColor: const Color(0xfff9f9f9), // AppBar màu trắng
        elevation: 0,
        title: Text(
          "ATSH CGV.",
          style: TextStyle(
            color: Colors.red, // Màu đỏ
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleSpacing: 20, // Đưa title về sát trái hơn
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300], // Màu xám nhẹ
                foregroundColor: Colors.black, // Màu chữ đen
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Bo góc nhẹ
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'Đăng nhập',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingData.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(onboardingData[index]["image"]!, width: 300),
                      SizedBox(height: 20),
                      Text(
                        onboardingData[index]["title"]!,
                        style: TextStyle(
                          color: Color(0xFF545454), // Màu #545454
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        onboardingData[index]["description"]!,
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Color(0xFF545454), fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SmoothPageIndicator(
            controller: _pageController,
            count: onboardingData.length,
            effect: ExpandingDotsEffect(
              activeDotColor: Color(0xFFEE0033), // Màu #c20077
              dotHeight: 8,
              dotWidth: 8,
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _goToHome,
                  child: Text(
                    "Bỏ qua",
                    style: TextStyle(color: Color(0xFF545454), fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEE0033), // Màu nền #c20077
                    foregroundColor: Colors.white, // Màu chữ trắng
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Bo tròn góc
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12), // Căn chỉnh kích thước
                  ),
                  child: Text(
                    _currentPage == onboardingData.length - 1
                        ? "Bắt đầu ngay"
                        : "Tiếp tục",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
