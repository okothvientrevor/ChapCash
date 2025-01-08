import 'package:chapcash/controllers/send_payment_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SendPaymentScreen extends StatelessWidget {
  SendPaymentScreen({super.key});

  final controller = Get.put(SendPaymentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Send Payment',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recipient Username',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.recipientController,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) => controller.verifyRecipient(value),
                  decoration: InputDecoration(
                    hintText: 'Enter username',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    suffixIcon: Obx(() => controller.isVerifying.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.blue,
                              ),
                            ),
                          )
                        : controller.isRecipientVerified.value
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : const SizedBox()),
                  ),
                ),
                // Recipient details with improved animation
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: Obx(() => controller.isRecipientVerified.value
                      ? Column(
                          children: [
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Sending to: ${controller.recipientFullName.value}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink()),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Amount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  onTap: () => controller.checkAndShowError(),
                  decoration: InputDecoration(
                    prefixText: 'UGX ',
                    prefixStyle: const TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'What is this payment for?',
                  ),
                ),
                const SizedBox(height: 32),
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (!controller.isRecipientVerified.value ||
                                controller
                                    .transactionController.isLoading.value)
                            ? null
                            : () async {
                                if (controller.amountController.text.isEmpty) {
                                  Get.snackbar(
                                    'Error',
                                    'Please enter an amount',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }

                                final amount = double.tryParse(
                                    controller.amountController.text);
                                if (amount == null || amount <= 0) {
                                  Get.snackbar(
                                    'Error',
                                    'Please enter a valid amount',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }

                                controller.showConfirmationDialog(
                                    context, amount);
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.transactionController.isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Send Payment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
