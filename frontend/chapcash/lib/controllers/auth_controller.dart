import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../routes/app_routes.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final error = RxString('');
  static const baseUrl = 'http://10.0.2.2:3000/api';
  final token = RxString('');
  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    // Check if token exists in storage
    String? storedToken = storage.read('token');
    if (storedToken != null) {
      token.value = storedToken;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        token.value = responseData['token'];
        // Store token
        await storage.write('token', token.value);
        Get.offAllNamed(AppRoutes.HOME);
      } else {
        error.value = 'Invalid credentials';
      }
    } catch (e) {
      error.value = 'Connection error';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    token.value = '';
    await storage.remove('token');
    Get.offAllNamed(AppRoutes.LANDING);
  }

  bool get isAuthenticated => token.value.isNotEmpty;

  Future<void> register(
      String name, String username, String email, String password) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        Get.offAllNamed(AppRoutes.LOGIN);
      } else {
        error.value = response.body;
      }
    } catch (e) {
      error.value = 'Connection error';
    } finally {
      isLoading.value = false;
    }
  }
}
