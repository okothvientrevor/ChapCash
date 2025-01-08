import 'package:chapcash/screens/deposit_screen.dart';
import 'package:chapcash/screens/send_payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final RxBool showBalance = true.obs;
  final userController = Get.find<UserController>();
  final transactionController = Get.find<TransactionController>();
  final authController = Get.find<AuthController>();

  @override
  void onInit() {
    // Initial data fetch
    _fetchUserData();

    // Set up periodic refresh (every 30 seconds)
    ever(transactionController.transactions, (_) {
      print('Transactions updated');
      _fetchUserData();
    });

    // Debug print the token
    print('Current token: ${authController.token.value}');
  }

  Future<void> _fetchUserData() async {
    print('Fetching user data...');
    await userController.getProfile();
    print('Profile data: ${userController.profile}');
    await transactionController.getTransactionHistory();
    print('Transaction history fetched');
  }

  @override
  Widget build(BuildContext context) {
    // Initial data fetch when screen loads
    _fetchUserData();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Top Row with Avatar and Welcome Message
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/images/avatar.png'),
                    ),
                    Obx(() => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${userController.profile.value['name'] ?? 'User'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Good Morning',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )),
                    IconButton(
                      icon:
                          const Icon(Icons.notifications, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Balance Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Available Balance',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: Obx(() => Icon(
                                  showBalance.value
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white70,
                                )),
                            onPressed: () => showBalance.toggle(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Text(
                            showBalance.value
                                ? 'UGX ${userController.profile.value['balance']?.toStringAsFixed(2) ?? '0.00'}'
                                : '••••••',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                        Icons.arrow_downward, 'Deposit', Colors.green),
                    _buildActionButton(Icons.send, 'Send', Colors.blue),
                    _buildActionButton(
                        Icons.arrow_upward, 'Withdraw', Colors.orange),
                    _buildActionButton(
                        Icons.receipt_long, 'Bills', Colors.purple),
                  ],
                ),

                const SizedBox(height: 24),

                // Recent Transactions
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recent Transactions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Transaction List
                Obx(() => ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactionController.transactions.length,
                      itemBuilder: (context, index) {
                        final transaction =
                            transactionController.transactions[index];
                        return _buildTransactionItem(
                          transaction['description'] ?? 'Transaction',
                          DateTime.parse(transaction['createdAt']),
                          transaction['amount'].toDouble(),
                        );
                      },
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        switch (label) {
          case 'Deposit':
            // Handle deposit
            print('Deposit tapped');
            Get.to(() => DepositScreen());
            break;
          case 'Send':
            // Handle send
            print('Send tapped');
            Get.to(() => SendPaymentScreen());
            break;
          case 'Withdraw':
            // Handle withdraw
            print('Withdraw tapped');
            break;
          case 'Bills':
            // Handle bills
            print('Bills tapped');
            break;
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String title, DateTime date, double amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Text(
                '${date.day}/${date.month}/${date.year}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            '${amount >= 0 ? '+' : ''}\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: amount >= 0 ? Colors.green : Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
