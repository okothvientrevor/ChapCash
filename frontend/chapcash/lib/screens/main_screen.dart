import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_screen.dart';
import 'activity_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentIndex = 0.obs;

    final screens = [
      HomeScreen(),
      ActivityScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: Obx(() => screens[currentIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: currentIndex.value,
          onTap: (index) => currentIndex.value = index,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Activity',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
