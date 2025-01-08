import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackbar {
  static void showSuccess({
    required String title,
    required String message,
    Duration? duration,
  }) {
    Get.snackbar(
      '',
      '',
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade800,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: duration ?? const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      icon: const Icon(
        Icons.check_circle_outline,
        color: Colors.white,
        size: 28,
      ),
      shouldIconPulse: true,
      leftBarIndicatorColor: Colors.green,
    );
  }

  static void showError({
    required String title,
    required String message,
    Duration? duration,
  }) {
    Get.snackbar(
      '',
      '',
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade800,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: duration ?? const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      icon: const Icon(
        Icons.error_outline,
        color: Colors.white,
        size: 28,
      ),
      shouldIconPulse: true,
      leftBarIndicatorColor: Colors.red,
    );
  }

  static void showWarning({
    required String title,
    required String message,
    Duration? duration,
  }) {
    Get.snackbar(
      '',
      '',
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade800,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: duration ?? const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: Colors.white,
        size: 28,
      ),
      shouldIconPulse: true,
      leftBarIndicatorColor: Colors.orange,
    );
  }

  static void showInfo({
    required String title,
    required String message,
    Duration? duration,
  }) {
    Get.snackbar(
      '',
      '',
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade800,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: duration ?? const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      icon: const Icon(
        Icons.info_outline,
        color: Colors.white,
        size: 28,
      ),
      shouldIconPulse: true,
      leftBarIndicatorColor: Colors.blue,
    );
  }
}
