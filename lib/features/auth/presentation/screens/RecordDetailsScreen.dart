import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/models/transaction_model.dart';
// လိုအပ်သော Bloc နှင့် အခြား model မားကို ဤနေရာတွင် import လုပ်ပါ

class RecordDetailsScreen extends StatelessWidget {
  final TransactionItem transaction;
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;

  const RecordDetailsScreen({
    Key? key,
    required this.transaction,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0');
    final isExpense = transaction.type == 'expense';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFEDE7F6), // ခရမ်းနုရောင် background
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black),
            ),
          ),
        ),
        title: const Text(
          "Record Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.close, size: 18, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Icon & Name Row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: categoryColor,
                          child: Icon(categoryIcon, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          categoryName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Detail Rows
                    _buildDetailRow("Type", isExpense ? "Expense" : "Income"),
                    _buildDetailRow("Amount", formatter.format(transaction.amount)),
                    _buildDetailRow(
                      "Date", 
                      "${DateFormat('MMM d, yyyy').format(transaction.createdAt.toLocal())}\n(${DateFormat('HH:mm:ss').format(transaction.createdAt.toLocal())})",
                      isMultiLine: true,
                    ),
                    _buildDetailRow("Note", transaction.note.isNotEmpty ? transaction.note : "-"),
                    
                    // Photos Section
                    const SizedBox(height: 16),
                    const Text(
                      "Photos",
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    // ဥပမာအဖြစ် Image ဖော်ပြခြင်း (တကယ်သုံးလျှင် database သို့မဟုတ် file path မှ ဆွဲထုတ်ပါ)
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: const Icon(Icons.image, size: 40, color: Colors.grey), 
                        // သို့မဟုတ် Image.network/file သုံးရန်
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Action Buttons (Edit & Delete)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Handle Edit Action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("Edit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Handle Delete Action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9333EA).withOpacity(0.8), // ခရမ်းရောင် သို့မဟုတ် design အတိုင်းပြောင်းနိုင်သည်
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isMultiLine = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: label == "Amount" ? FontWeight.bold : FontWeight.normal,
                color: Colors.black12 ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}