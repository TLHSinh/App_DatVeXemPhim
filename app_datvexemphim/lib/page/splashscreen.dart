// import 'package:animated_splash_screen/animated_splash_screen.dart';
// import 'package:app_datvexemphim/page/homepage.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';

// class Splashscreen extends StatelessWidget {
//   const Splashscreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedSplashScreen(
//       splash: Column(
//         children: [
//           Center(
//             child:
//                 Lottie.asset('assets/animationsplashscreen.json'),
//           )
//         ],
//       ),
//       nextScreen: const MyHomePage(),
//       duration: 3500,
//       backgroundColor: Colors.white,
//     );
//   }
// }

// import 'package:animated_splash_screen/animated_splash_screen.dart';
// import 'package:app_datvexemphim/page/homepage.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';

// class Splashscreen extends StatelessWidget {
//   const Splashscreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedSplashScreen(
//       splash: Lottie.asset('assets/animation/Animation - 1740246483371.json', width: 500, height: 500,),
//       nextScreen: const MyHomePage(),
//       duration: 3500,
//       centered: true,
//       backgroundColor: Colors.white,
//     );
//   }
// }

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:app_datvexemphim/page/login_logout/welcome.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Transform.scale(
        scale: 2.0,
        child: Lottie.asset('assets/animation/Animation - 1740246483371.json'),
      ),
      nextScreen: const Welcome(),
      duration: 3000,
      centered: true,
      backgroundColor: Colors.white,
    );
  }
}
