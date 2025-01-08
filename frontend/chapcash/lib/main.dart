import 'package:chapcash/bindings/app_binding.dart';
import 'package:chapcash/routes/app_pages.dart';
import 'package:chapcash/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Transaction App',
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      initialBinding: HomeBinding(),
      initialRoute: AppRoutes.LANDING,
      getPages: AppPages.pages,
    );
  }
}
