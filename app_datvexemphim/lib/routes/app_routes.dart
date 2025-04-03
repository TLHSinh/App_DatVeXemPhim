import 'package:app_datvexemphim/presentation/screens/detailprofile_screen.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/onboarding_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/register_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/account_screen.dart';
import '../presentation/screens/veryfyOTP_screen.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => SplashScreen()),
      GoRoute(
          path: '/onboarding', builder: (context, state) => OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
      GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
      GoRoute(
          path: '/detailProfile',
          builder: (context, state) => DetailprofileScreen()),
      GoRoute(path: '/profile', builder: (context, state) => ProfileScreen()),
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) {
          final email = state.extra as String; // Lấy email từ màn hình trước
          return OtpVerificationScreen(email: email);
        },
      ),
    ],
  );
}
