import 'package:app_datvexemphim/presentation/size_config.dart';
import 'package:flutter/material.dart';

double animatedPositionLeftValue (int currentIndex){
  switch (currentIndex) {
    case 0:
      return AppSizes.blockSizeHorizontal *8.8;
    case 1:
      return AppSizes.blockSizeHorizontal *32.2;
    case 2:
      return AppSizes.blockSizeHorizontal *55.7;
    case 3:
      return AppSizes.blockSizeHorizontal *79.3;
    default: 
      return 0;

  }
}

final List<Color> gradient = [
  Colors.yellow.withOpacity(0.5),
  Colors.yellow.withOpacity(0.3),
  Colors.transparent
];