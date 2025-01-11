import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/logos/chapcash_logo.png',
                height: 200,
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () => Get.toNamed(AppRoutes.LOGIN),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16), shadowColor: Colors.red),
                child: const Text('Login',
                    style: TextStyle(fontSize: 18, color: Colors.red)),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Get.toNamed(AppRoutes.REGISTER),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Register',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
