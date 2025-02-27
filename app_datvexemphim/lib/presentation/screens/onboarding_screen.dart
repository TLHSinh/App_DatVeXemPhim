import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/onboarding1.png",
      "title": "Chào mừng bạn đến với App!",
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
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    } else {
      _goToHome();
    }
  }

  void _goToHome() {
    context.go('/home'); // Điều hướng đến màn hình chính
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100), // Tăng chiều cao AppBar
        child: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: Align(
            alignment: Alignment.centerLeft, // Đưa logo về góc trái
            child: Image.asset(
              'assets/images/logo2.png',
              width: 150, // Kích thước logo lớn hơn
              height: 600,
              fit: BoxFit.contain,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TextButton(
                onPressed: () {
                  context.go('/login'); // Điều hướng đến trang đăng nhập
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  'Đăng nhập',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
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
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(onboardingData[index]["image"]!, width: 300),
                    SizedBox(height: 20),
                    Text(
                      onboardingData[index]["title"]!,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        onboardingData[index]["description"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SmoothPageIndicator(
            controller: _pageController,
            count: onboardingData.length,
            effect: ExpandingDotsEffect(
              activeDotColor: Colors.red,
              dotHeight: 8,
              dotWidth: 8,
            ),
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _goToHome,
                  child: Text("Bỏ qua",
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text(_currentPage == onboardingData.length - 1
                      ? "Bắt đầu"
                      : "Tiếp tục"),
                ),
              ],
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
