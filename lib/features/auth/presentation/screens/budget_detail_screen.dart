import 'package:flutter/material.dart';
import '../../../../models/budget_model.dart';

class BudgetDetailsScreen extends StatelessWidget {
  final BudgetItem budget;
  final VoidCallback onEditTap;
  final VoidCallback onRemoveTap;

  const BudgetDetailsScreen({
    super.key,
    required this.budget,
    required this.onEditTap,
    required this.onRemoveTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Color(0xFF8A4BEB)),
            title: const Text("Edit Budget"),
            onTap: () {
              Navigator.pop(context);
              onEditTap();
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text("Remove Budget"),
            onTap: () {
              Navigator.pop(context);
              onRemoveTap();
            },
          ),
        ],
      ),
    );
  }
}