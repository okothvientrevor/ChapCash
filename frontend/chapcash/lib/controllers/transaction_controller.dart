import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_controller.dart';
import 'user_controller.dart';

class TransactionController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final UserController userController = Get.find<UserController>();

  final transactions = RxList<Map<String, dynamic>>([]);
  final isLoading = false.obs;
  final error = RxString('');

  static const baseUrl = 'http://10.0.2.2:3000/api';

  Future<void> deposit(double amount) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await http.post(
        Uri.parse('$baseUrl/deposit'),
        headers: {
          'Authorization': 'Bearer ${authController.token.value}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        await getTransactionHistory();
        await userController.getProfile();
      } else {
        error.value = 'Error processing deposit';
      }
    } catch (e) {
      error.value = 'Connection error';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendPayment(String recipientUsername, double amount) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await http.post(
        Uri.parse('$baseUrl/payments'),
        headers: {
          'Authorization': 'Bearer ${authController.token.value}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'recipientUsername': recipientUsername,
          'amount': amount,
        }),
      );

      if (response.statusCode == 201) {
        await getTransactionHistory();
        await userController.getProfile();
      } else {
        error.value = response.body;
      }
    } catch (e) {
      error.value = 'Connection error';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getTransactionHistory() async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await http.get(
        Uri.parse('$baseUrl/payments'),
        headers: {
          'Authorization': 'Bearer ${authController.token.value}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        transactions.value =
            data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        error.value = 'Error fetching transactions';
      }
    } catch (e) {
      error.value = 'Connection error';
    } finally {
      isLoading.value = false;
    }
  }
}
