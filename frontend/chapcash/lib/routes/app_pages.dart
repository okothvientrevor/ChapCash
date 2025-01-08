import 'package:chapcash/bindings/app_binding.dart';
import 'package:chapcash/screens/main_screen.dart';
import 'package:get/get.dart';
import '../screens/home_screen.dart';
import '../screens/landing_screen.dart';
import '../screens/login_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomeScreen(),
      binding: HomeBinding(), // Add this line
    ),
    GetPage(
      name: AppRoutes.LANDING,
      page: () => const LandingScreen(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.MAIN,
      page: () => const MainScreen(),
    ),
  ];
}
