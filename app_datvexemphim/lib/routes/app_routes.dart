import 'package:go_router/go_router.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/onboarding_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/register_screen.dart';
import '../presentation/screens/home_screen.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
      GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
    ],
  );
}
