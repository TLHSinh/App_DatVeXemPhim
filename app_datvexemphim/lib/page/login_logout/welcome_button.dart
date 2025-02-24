// import 'package:app_datvexemphim/page/login_logout/signin.dart';
// import 'package:flutter/material.dart';

// class WelcomeButton extends StatelessWidget {
//   const WelcomeButton({super.key, this.buttonText, this.onTap, this.color});
//   final String? buttonText;
//   final Widget? onTap;
//   final Color? color;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap:() {
//         Navigator.push(
//           context, 
//           MaterialPageRoute(
//             builder: (e) => onTap!,
//             ),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.all(30.0),
//         decoration:  BoxDecoration(
//           color: color!,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(50),
//           ),
//         ),
//         child: Text(
//           buttonText!,
//           textAlign: TextAlign.center,
//           style: const  TextStyle(
//           fontSize: 20.0,
//           fontWeight: FontWeight.bold,
//         ),),
//       ),
//     );
//   }
// }





// import 'package:flutter/material.dart';

// class WelcomeButton extends StatelessWidget {
//   const WelcomeButton({
//     super.key,
//     required this.buttonText,
//     required this.onTap,
//     this.color,
//   });

//   final String buttonText;
//   final VoidCallback onTap;
//   final Color? color;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(15.0),
//         decoration: BoxDecoration(
//           color: color ?? Colors.white,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Center(
//           child: Text(
//             buttonText,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 20.0,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

class WelcomeButton extends StatelessWidget {
  const WelcomeButton({
    super.key,
    required this.buttonText,
    required this.onTap,
    required this.backgroundColor,
    required this.textColor,
  });

  final String buttonText;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Center(
          child: Text(
            buttonText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

