import 'package:app_datvexemphim/presentation/screens/onboarding_screen.dart';
import 'package:app_datvexemphim/presentation/screens/payment_successful.dart';
import 'package:app_datvexemphim/presentation/widgets/final_view.dart';
import 'package:app_links/app_links.dart';
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

  final uri = Uri.base; // Nhận deep link từ hệ thống
  if (uri.scheme == "appdatvexemphim" && uri.host == "payment-success") {
    print("Nhận deep link: ${uri.queryParameters}");
  }
  runApp(MyApp()); // Chạy app sau khi Firebase đã được khởi tạo
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;
  final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => SplashScreen()),
      GoRoute(path: '/loading', builder: (context, state) => LoadingScreen()),
      GoRoute(
          path: '/onboarding', builder: (context, state) => OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
      GoRoute(path: '/home', builder: (context, state) => FinalView()),
      GoRoute(
          path: '/payment-success',
          builder: (context, state) => PaymentSuccessful()),
      GoRoute(
          path: '/detailProfile',
          builder: (context, state) => DetailprofileScreen()),
    ],
  );

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _handleDeepLinks();
  }

  void _handleDeepLinks() async {
    // Khi app đang chạy và nhận deep link mới
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _navigateToDeepLink(uri);
      }
    });

    // Khi app mở từ deep link lần đầu tiên
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _navigateToDeepLink(initialUri);
    }
  }

  void _navigateToDeepLink(Uri uri) {
    if (uri.path == '/payment-success') {
      final params = uri.queryParameters; // Lấy query parameters từ MoMo
      print("Thanh toán thành công: $params");

      // Chỉ điều hướng nếu app đang mở
      if (mounted) {
        _router.go('/payment-success', extra: params);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
