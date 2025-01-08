import 'package:chapcash/widgets/custom_alert_dialog.dart';
import 'package:chapcash/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../controllers/transaction_controller.dart';
import '../controllers/user_controller.dart';

class SendPaymentController extends GetxController {
  final TransactionController transactionController =
      Get.find<TransactionController>();
  final UserController userController = Get.find<UserController>();

  final recipientController = TextEditingController();
  final amountController = TextEditingController();

  final isRecipientVerified = false.obs;
  final recipientFullName = ''.obs;
  final isVerifying = false.obs;
  final hasSearched = false.obs;
  final showUserNotFoundError = false.obs;

  Timer? _debounceTimer;

  @override
  void onClose() {
    _debounceTimer?.cancel();
    recipientController.dispose();
    amountController.dispose();
    super.onClose();
  }

  Future<void> verifyRecipient(String username) async {
    isRecipientVerified.value = false;
    recipientFullName.value = '';
    showUserNotFoundError.value = false;

    if (username.isEmpty) {
      isVerifying.value = false;
      hasSearched.value = false;
      return;
    }

    _debounceTimer?.cancel();
    isVerifying.value = true;

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final user = await userController.findUserByUsername(username);
        hasSearched.value = true;

        if (user != null && user['name'] != null) {
          recipientFullName.value = user['name'];
          isRecipientVerified.value = true;
          showUserNotFoundError.value = false;
        } else {
          showUserNotFoundError.value = true;
          isRecipientVerified.value = false;
        }
      } catch (e) {
        showUserNotFoundError.value = true;
        isRecipientVerified.value = false;
      } finally {
        isVerifying.value = false;
      }
    });
  }

  void checkAndShowError() {
    if (showUserNotFoundError.value) {
      CustomSnackbar.showError(
        title: 'User Not Found',
        message:
            'The username you entered could not be found. Please try again.',
      );
    }
  }

  void showConfirmationDialog(BuildContext context, double amount) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Confirm Payment',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to send UGX ${amount.toStringAsFixed(2)} to ${recipientFullName.value}?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await processSendPayment(amount);
            },
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> processSendPayment(double amount) async {
    await transactionController.sendPayment(
      recipientController.text,
      amount,
    );

    if (transactionController.error.isEmpty) {
      Get.back();
      CustomSnackbar.showSuccess(
        title: 'Success',
        message: 'Payment sent successfully',
      );
    } else {
      CustomSnackbar.showError(
        title: 'Error',
        message: transactionController.error.value,
      );
    }
  }
}
