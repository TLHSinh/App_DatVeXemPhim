import 'package:app_datvexemphim/presentation/screens/gift_screen.dart';
import 'package:app_datvexemphim/presentation/screens/home_screen.dart';
import 'package:app_datvexemphim/presentation/screens/location_screen.dart';
import 'package:app_datvexemphim/presentation/size_config.dart';
import 'package:app_datvexemphim/presentation/widgets/bottom_nav_btn.dart';
import 'package:app_datvexemphim/presentation/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import '../screens/account_screen.dart';

class FinalView extends StatefulWidget {
  const FinalView({super.key});

  @override
  State<FinalView> createState() => _FinalViewState();
}

class _FinalViewState extends State<FinalView> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    const LocationScreen(),
    const GiftScreen(),
    const ProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    AppSizes().init(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(child: _screens[_currentIndex]),
            Positioned(bottom: 0, right: 0, left: 0, child: bottomNav()),
          ],
        ),
      ),
    );
  }


Widget bottomNav() {
  return Padding(
    padding: EdgeInsets.fromLTRB(
      AppSizes.blockSizeHorizontal * 0,
      0,
      AppSizes.blockSizeHorizontal * 0,
      0,
    ),
    child: Material(
      color: Colors.transparent,
      elevation: 10, // Bóng đổ cho Material (nếu cần)
      child: Container(
        height: AppSizes.blockSizeHorizontal * 18,
        width: AppSizes.screenWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Màu bóng đổ
              blurRadius: 10, // Độ mờ của bóng
              spreadRadius: 2, // Độ lan rộng của bóng
              offset: const Offset(0, -3), // Vị trí bóng (x, y)
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              top: 0,
              left: AppSizes.blockSizeHorizontal * 3,
              right: AppSizes.blockSizeHorizontal * 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BottomNavBtn(
                    icon: LineAwesome.home_solid,
                    label: "Trang chủ",
                    currentIndex: _currentIndex,
                    index: 0,
                    onPress: (val) {
                      setState(() {
                        _currentIndex = val;
                      });
                    },
                  ),
                  BottomNavBtn(
                    icon: FontAwesome.location_dot_solid,
                    label: "Rạp phim",
                    currentIndex: _currentIndex,
                    index: 1,
                    onPress: (val) {
                      setState(() {
                        _currentIndex = val;
                      });
                    },
                  ),
                  BottomNavBtn(
                    icon: FontAwesome.gift_solid,
                    label: "Quà tặng",
                    currentIndex: _currentIndex,
                    index: 2,
                    onPress: (val) {
                      setState(() {
                        _currentIndex = val;
                      });
                    },
                  ),
                  BottomNavBtn(
                    icon: FontAwesome.user,
                    label: "Tài khoản",
                    currentIndex: _currentIndex,
                    index: 3,
                    onPress: (val) {
                      setState(() {
                        _currentIndex = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(microseconds: 300),
              curve: Curves.decelerate,
              left: animatedPositionLeftValue(_currentIndex),
              child: Column(
                children: [
                  Container(
                    height: AppSizes.blockSizeHorizontal * 1.0,
                    width: AppSizes.blockSizeHorizontal * 12,
                    decoration: BoxDecoration(
                      color: const Color(0xffb20710),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
