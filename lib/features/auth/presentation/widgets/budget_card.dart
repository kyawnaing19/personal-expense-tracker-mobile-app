import 'package:flutter/material.dart';
import '../../../../models/budget_model.dart';
import '../screens/budget_utils.dart';
import 'budget_ring_painter.dart';

class BudgetCard extends StatelessWidget {
  final BudgetItem budget;
  final VoidCallback onMenuTap;

  const BudgetCard({super.key, required this.budget, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final bool exceeded = budget.isExceeded;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: budget.categoryColor,
                child: Icon(budget.categoryIcon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  budget.categoryName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              GestureDetector(
                onTap: onMenuTap,
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.more_vert, color: Colors.black54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CustomPaint(
                  painter: BudgetRingPainter(percentage: budget.percentage, isExceeded: exceeded),
                  child: Center(
                    child: exceeded
                        ? const Text(
                            "Exceed",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFE64A4A)),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Expense", style: TextStyle(fontSize: 9, color: Colors.grey)),
                              Text(
                                "${budget.percentage.toStringAsFixed(2)}%",
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _dataRow("Budget :", formatAmount(budget.budget)),
                    const SizedBox(height: 6),
                    _dataRow("Expenses :", formatAmount(budget.spent)),
                    // The divider sits below BOTH Budget and Expenses —
                    // right above Remaining — not under the header.
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Divider(thickness: 1, height: 1, color: Color(0xFFE0E0E0)),
                    ),
                    _dataRow("Remaining :", formatAmount(budget.remaining)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Notify me when my remaining budget reaches ${budget.alertPercentage}%.",
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _dataRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      );
}