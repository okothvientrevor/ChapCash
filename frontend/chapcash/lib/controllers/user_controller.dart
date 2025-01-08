import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_controller.dart';

class UserController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final profile = Rx<Map<String, dynamic>>({});
  final isLoading = false.obs;
  final error = RxString('');

  static const baseUrl = 'http://10.0.2.2:3000/api';

  Future<void> getProfile() async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer ${authController.token.value}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        profile.value = json.decode(response.body);
      } else {
        error.value = 'Error fetching profile';
      }
    } catch (e) {
      error.value = 'Connection error';
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> findUserByUsername(String username) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await http.get(
        Uri.parse('$baseUrl/user/$username'),
        headers: {
          'Authorization': 'Bearer ${authController.token.value}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        error.value = 'User not found';
        return null;
      }
    } catch (e) {
      error.value = 'Connection error';
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
