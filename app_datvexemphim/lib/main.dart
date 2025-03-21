import 'package:app_datvexemphim/presentation/screens/onboarding_screen.dart';
import 'package:app_datvexemphim/presentation/widgets/final_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_datvexemphim/presentation/screens/splash_screen.dart';
import 'package:app_datvexemphim/presentation/screens/loading_screen.dart';
import 'package:app_datvexemphim/presentation/screens/login_screen.dart';
import 'package:app_datvexemphim/presentation/screens/register_screen.dart';
import 'package:app_datvexemphim/presentation/screens/detailprofile_screen.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('vi_VN', null);

  // Chờ Firebase khởi tạo trước khi chạy ứng dụng
  {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(MyApp()); // Chạy app sau khi Firebase đã được khởi tạo
}

class MyApp extends StatelessWidget {
  final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: '/loading',
        builder: (context, state) => LoadingScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => FinalView(),
      ),
      GoRoute(
        path: '/detailProfile',
        builder: (context, state) => DetailprofileScreen(),
      ),
    ],
  );

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
