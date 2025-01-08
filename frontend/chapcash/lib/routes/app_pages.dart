import 'package:chapcash/routes/app_routes.dart';
import 'package:get/get.dart';
import '../screens/landing_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../controllers/auth_controller.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.LANDING,
      page: () => const LandingScreen(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomeScreen(),
    ),
  ];
}
