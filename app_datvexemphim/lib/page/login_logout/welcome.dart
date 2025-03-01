// import 'package:app_datvexemphim/page/login_logout/log_widget.dart';
// import 'package:app_datvexemphim/page/login_logout/signin.dart';
// import 'package:app_datvexemphim/page/login_logout/signup.dart';
// import 'package:app_datvexemphim/page/login_logout/welcome_button.dart';
// import 'package:flutter/material.dart';

// class Welcome extends StatelessWidget {
//   const Welcome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return LogWidget(
//       child: Column(
//         children: [
//           Flexible(
//               flex: 8,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 0,
//                   horizontal: 40.0,
//                 ),
//                 child: Center(
//                   child: RichText(
//                     textAlign: TextAlign.center,
//                     text: const TextSpan(
//                       children: [
//                         TextSpan(
//                             text: 'Welcome to ATSH',
//                             style: TextStyle(
//                               fontSize: 45.0,
//                               fontWeight: FontWeight.w600,
//                             ))
//                       ],
//                     ),
//                   ),
//                 ),
//               )),
//           const Flexible(
//               flex: 1,
//               child: Align(
//                 alignment: Alignment.bottomRight,
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: WelcomeButton(
//                         buttonText: 'Đăng nhập',
//                         onTap: Signin(),
//                         color: Colors.transparent,
//                       ),
//                     ),
//                     Expanded(
//                       child: WelcomeButton(
//                         buttonText: 'Đăng ký',
//                         onTap: Signup(),
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               )),
//         ],
//       ),
//     );
//   }
// }




// import 'package:app_datvexemphim/page/login_logout/log_widget.dart';
// import 'package:app_datvexemphim/page/login_logout/signin.dart';
// import 'package:app_datvexemphim/page/login_logout/signup.dart';
// import 'package:app_datvexemphim/page/login_logout/welcome_button.dart';
// import 'package:flutter/material.dart';

// class Welcome extends StatelessWidget {
//   const Welcome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return LogWidget(
//       child: Column(
//         children: [
//           Flexible(
//             flex: 8,
//             child: Container(
//               padding: const EdgeInsets.symmetric(
//                 vertical: 0,
//                 horizontal: 40.0,
//               ),
//               child: const Center(
//                 child: Text(
//                   'Welcome to ATSH',
//                   style: TextStyle(
//                     fontSize: 45.0,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//           ),
//           Flexible(
//             flex: 1,
//             child: Align(
//               alignment: Alignment.bottomRight,
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: WelcomeButton(
//                       buttonText: 'Đăng nhập',
//                       onTap: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => const Signin()),
//                       ),
//                       color: Colors.grey,
//                     ),
//                   ),
//                   Expanded(
//                     child: WelcomeButton(
//                       buttonText: 'Đăng ký',
//                       onTap: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => const Signup()),
//                       ),
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }






import 'package:app_datvexemphim/page/login_logout/log_widget.dart';
import 'package:app_datvexemphim/page/login_logout/signin.dart';
import 'package:app_datvexemphim/page/login_logout/signup.dart';
import 'package:app_datvexemphim/page/login_logout/welcome_button.dart';
import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return LogWidget(
      child: Column(
        children: [
          Flexible(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 40.0,
              ),
              child: const Center(
                child: Text(
                  'Welcome to ATSH',
                  style: TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Đăng nhập',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Signin()),
                      ),
                      // backgroundColor: Colors.white.withOpacity(0.3),
                      // backgroundColor: Color.fromARGB(0, 229, 161, 15),
                      backgroundColor: const Color(0xFF002e5a),
                      textColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Đăng ký',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Signup()),
                      ),
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
