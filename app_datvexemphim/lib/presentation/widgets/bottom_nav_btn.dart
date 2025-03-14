import 'package:app_datvexemphim/presentation/size_config.dart';
import 'package:flutter/material.dart';

class BottomNavBtn extends StatelessWidget {
  const BottomNavBtn(
      {super.key,
      required this.icon,
      required this.label,
      required this.index,
      required this.currentIndex,
      required this.onPress});

  final IconData icon;
  final String label;
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
          height: AppSizes.blockSizeHorizontal * 16, // Tăng chiều cao
          width: AppSizes.blockSizeHorizontal * 17,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: (currentIndex == index)
                    ? const Color(0xffee0033)
                    : const Color(0xffb9b9b9),
                size: AppSizes.blockSizeHorizontal * 7,
              ),
              SizedBox(
                  height:
                      AppSizes.blockSizeHorizontal * 0.5), // Giảm khoảng cách
              Text(
                label,
                style: TextStyle(
                  color: (currentIndex == index)
                      ? const Color(0xffee0033) // Màu đỏ khi được chọn
                      : const Color(0xffb9b9b9), // Màu đen khi không được chọn
                  fontSize: AppSizes.blockSizeHorizontal *
                      2.8, // Giảm kích thước font
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )),
    );
  }
}
