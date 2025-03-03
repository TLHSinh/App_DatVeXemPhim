import 'package:app_datvexemphim/presentation/size_config.dart';
import 'package:flutter/material.dart';

class BottomNavBtn extends StatelessWidget {
  const BottomNavBtn(
      {super.key,
      required this.icon,
      required this.index,
      required this.currentIndex,
      required this.onPress});

  final IconData icon;
  final int index;
  final int currentIndex;
  final Function(int) onPress;

  @override
  Widget build(BuildContext context) {
    AppSizes().init(context);
    return InkWell(
      onTap: () {
        onPress(index);
      },
      child: Container(
          height: AppSizes.blockSizeHorizontal * 13,
          width: AppSizes.blockSizeHorizontal * 17,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              (currentIndex == index)
                  ? Positioned(
                      left: AppSizes.blockSizeHorizontal * 4,
                      bottom: AppSizes.blockSizeHorizontal * 1.5,
                      child: Icon(
                        icon,
                        color: Colors.black,
                        size: AppSizes.blockSizeHorizontal * 8,
                      ),
                    )
                  : Container(),
              AnimatedOpacity(
                opacity: (currentIndex == index) ? 1 : .2,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
                child: Icon(
                  icon,
                  color: const Color(0xFFFFFFFF),
                  size: AppSizes.blockSizeHorizontal * 8,
                ),
              ),
            ],
          )),
    );
  }
}
