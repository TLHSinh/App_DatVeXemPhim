import 'package:app_datvexemphim/presentation/screens/gift_screen.dart';
import 'package:app_datvexemphim/presentation/screens/home_screen.dart';
import 'package:app_datvexemphim/presentation/screens/location_screen.dart';
import 'package:app_datvexemphim/presentation/size_config.dart';
import 'package:app_datvexemphim/presentation/widgets/bottom_nav_btn.dart';
import 'package:app_datvexemphim/presentation/widgets/clipper.dart';
import 'package:app_datvexemphim/presentation/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

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
    const Center(
        child: Text("Profile Screen", style: TextStyle(color: Colors.white))),
  ];

  @override
  Widget build(BuildContext context) {
    AppSizes().init(context);
    return Scaffold(
      backgroundColor: const Color(0xFF363636),
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

// build bottom nav
  Widget bottomNav() {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSizes.blockSizeHorizontal * 0, 0,
          AppSizes.blockSizeHorizontal * 0, 0),
      child: Material(
        color: Colors.transparent,
        elevation: 10,
        child: Container(
          height: AppSizes.blockSizeHorizontal * 18,
          width: AppSizes.screenWidth,
          decoration: BoxDecoration(
            color: Colors.grey[900],
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
                        currentIndex: _currentIndex,
                        index: 0,
                        onPress: (val) {
                          setState(() {
                            _currentIndex = val;
                          });
                        }),
                    BottomNavBtn(
                      icon: FontAwesome.location_dot_solid,
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
                        currentIndex: _currentIndex,
                        index: 3,
                        onPress: (val) {
                          setState(() {
                            _currentIndex = val;
                          });
                        }),
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
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    ClipPath(
                      clipper: MyCustomClipper(),
                      child: Container(
                        height: AppSizes.blockSizeHorizontal * 15,
                        width: AppSizes.blockSizeHorizontal * 12,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                          colors: gradient,
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )),
                      ),
                    )
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
