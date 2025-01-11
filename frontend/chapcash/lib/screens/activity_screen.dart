import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transaction_controller.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';

class ActivityScreen extends StatelessWidget {
  ActivityScreen({super.key});

  final transactionController = Get.find<TransactionController>();
  final NumberFormat currencyFormat = NumberFormat('#,##0', 'en_US');
  final DateFormat dateFormat = DateFormat('d/M/y');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Transaction History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Sent',
                    Colors.red.withOpacity(0.2),
                    Icons.arrow_upward,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Received',
                    Colors.green.withOpacity(0.2),
                    Icons.arrow_downward,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Transaction Table
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(() {
                  if (transactionController.transactions.isEmpty) {
                    return const Center(
                      child: Text(
                        'No transactions to display',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return DataTable2(
                    columnSpacing: 8,
                    horizontalMargin: 8,
                    minWidth: 400,
                    dataRowHeight: 48,
                    headingRowHeight: 40,
                    columns: [
                      DataColumn2(
                        label: _buildColumnHeader('Date'),
                        size: ColumnSize.S,
                      ),
                      DataColumn2(
                        label: _buildColumnHeader('Username'),
                        size: ColumnSize.S,
                      ),
                      DataColumn2(
                        label: _buildColumnHeader('Amount'),
                        size: ColumnSize.S,
                        numeric: true,
                      ),
                      DataColumn2(
                        label: _buildColumnHeader('Status'),
                        size: ColumnSize.S,
                      ),
                    ],
                    rows: transactionController.transactions.map((transaction) {
                      final DateTime date =
                          DateTime.parse(transaction['createdAt']);
                      final double amount = transaction['amount'].toDouble();
                      final bool isCredit = amount > 0;
                      String username = 'Deposit';

                      if (transaction['senderDetails'] != null &&
                          transaction['recipientDetails'] != null) {
                        username = isCredit
                            ? transaction['senderDetails']['username'] ??
                                transaction['senderDetails']['name']
                            : transaction['recipientDetails']['username'] ??
                                transaction['recipientDetails']['name'];
                      }

                      return DataRow(
                        cells: [
                          DataCell(Text(
                            dateFormat.format(date),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          )),
                          DataCell(Text(
                            username,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          )),
                          DataCell(Text(
                            '${isCredit ? '+' : '-'}UGX ${currencyFormat.format(amount.abs())}',
                            style: TextStyle(
                              color: isCredit ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          )),
                          DataCell(_buildStatusChip(
                              transaction['status'] ?? 'completed')),
                        ],
                      );
                    }).toList(),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'completed':
        chipColor = Colors.green;
        break;
      case 'pending':
        chipColor = Colors.orange;
        break;
      case 'failed':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.capitalize!,
        style: TextStyle(
          color: chipColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, Color bgColor, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            double total = 0;
            for (var transaction in transactionController.transactions) {
              double amount = transaction['amount'].toDouble();
              if ((title == 'Total Sent' && amount < 0) ||
                  (title == 'Total Received' && amount > 0)) {
                total += amount.abs();
              }
            }
            return Text(
              'UGX ${currencyFormat.format(total)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            );
          }),
        ],
      ),
    );
  }
}
