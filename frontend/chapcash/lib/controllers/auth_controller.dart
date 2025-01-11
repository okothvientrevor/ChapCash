import 'package:chapcash/widgets/custom_snack_bar.dart';
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
  final userData = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    _initializeStoredData();
  }

  Future<void> _initializeStoredData() async {
    try {
      String? storedToken = storage.read('token');
      if (storedToken != null) {
        token.value = storedToken;
        await _fetchUserData();
      }
    } catch (e) {
      _handleError('Error initializing data');
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token.value}',
        },
      );

      if (response.statusCode == 200) {
        userData.value = json.decode(response.body);
      } else {
        await logout();
      }
    } catch (e) {
      _handleError('Error fetching user data');
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

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        token.value = responseData['token'];
        await storage.write('token', token.value);

        if (responseData['user'] != null) {
          userData.value = responseData['user'];
        }

        CustomSnackbar.showSuccess(
          title: 'Welcome Back!',
          message: 'You have successfully logged in.',
        );

        Get.offAllNamed(AppRoutes.MAIN);
      } else {
        // Extract error message from response
        String errorMessage = 'Login failed';
        if (responseData != null) {
          if (responseData is Map<String, dynamic>) {
            errorMessage = responseData['error'] ??
                responseData['message'] ??
                'Invalid credentials';
          } else if (responseData is String) {
            errorMessage = responseData;
          }
        }
        _handleError(errorMessage);
      }
    } on http.ClientException catch (_) {
      _handleError(
          'Unable to connect to the server. Please check your internet connection.');
    } catch (e) {
      _handleError('Invalid Credentials. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(
      String name, String username, String email, String password) async {
    try {
      isLoading.value = true;
      error.value = '';

      if (!GetUtils.isEmail(email)) {
        _handleError('Please enter a valid email address');
        return;
      }

      if (password.length < 6) {
        _handleError('Password must be at least 6 characters long');
        return;
      }

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

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        CustomSnackbar.showSuccess(
          title: 'Registration Successful',
          message: 'Please login with your new account.',
        );
        Get.offAllNamed(AppRoutes.LOGIN);
      } else {
        String errorMessage = 'Registration failed';

        if (responseData != null && responseData is Map<String, dynamic>) {
          // Get both error message and details if available
          String errorText = responseData['error'] ?? '';
          String details = responseData['details'] ?? '';

          // Check for specific error patterns in either error or details
          if (details.contains('duplicate key error')) {
            if (details.contains('email_1 dup key')) {
              errorMessage =
                  'Email already exists. Please use a different email address.';
            } else if (details.contains('username_1 dup key')) {
              errorMessage =
                  'Username already exists. Please choose another username.';
            }
          } else if (errorText.contains('username is already taken')) {
            errorMessage =
                'Username already exists. Please choose another username.';
          } else if (errorText.contains('email is already registered')) {
            errorMessage =
                'Email already exists. Please use a different email address.';
          } else {
            // Fallback to the error message from the API if no specific pattern is matched
            errorMessage = errorText.isNotEmpty
                ? errorText
                : 'Registration failed. Please try again.';
          }
        }

        _handleError(errorMessage);
      }
    } on http.ClientException catch (_) {
      _handleError(
          'Unable to connect to the server. Please check your internet connection.');
    } catch (e) {
      _handleError('An unexpected error occurred. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void _handleError(String message) {
    // Clean up the message by removing any JSON formatting
    String cleanMessage = message.replaceAll(RegExp(r'[{}"\[\]]'), '');
    // If the message starts with "error:", remove it
    cleanMessage = cleanMessage.replaceFirst(
        RegExp(r'^error:\s*', caseSensitive: false), '');

    error.value = cleanMessage;
    CustomSnackbar.showError(
      title: 'Error',
      message: cleanMessage,
    );
  }

  Future<void> logout() async {
    try {
      token.value = '';
      userData.value = null;
      await storage.remove('token');

      CustomSnackbar.showInfo(
        title: 'Logged Out',
        message: 'You have been successfully logged out.',
      );

      Get.offAllNamed(AppRoutes.LANDING);
    } catch (e) {
      _handleError('Error during logout');
    }
  }

  bool get isAuthenticated => token.value.isNotEmpty;
  String get userName => userData.value?['name'] ?? '';
  bool get isUserDataLoaded => userData.value != null;
}
