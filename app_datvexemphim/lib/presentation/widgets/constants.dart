import 'package:app_datvexemphim/presentation/size_config.dart';

double animatedPositionLeftValue(int currentIndex) {
  switch (currentIndex) {
    case 0:
      return AppSizes.blockSizeHorizontal * 6.5;
    case 1:
      return AppSizes.blockSizeHorizontal * 25;
    case 2:
      return AppSizes.blockSizeHorizontal * 43.9;
    case 3:
      return AppSizes.blockSizeHorizontal * 63;
    case 4:
      return AppSizes.blockSizeHorizontal * 81.5;
    default:
      return 0;
  }
}
