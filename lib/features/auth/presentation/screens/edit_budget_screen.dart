import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/budget_model.dart';
import '../../../../models/category_model.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';
import '../widgets/budget_form.dart';

class EditBudgetScreen extends StatelessWidget {
  final BudgetItem budget;

  const EditBudgetScreen({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    final initialCategory = CategoryItem(
      id: budget.categoryId,
      name: budget.categoryName,
      icon: budget.categoryIcon,
      color: budget.categoryColor,
      type: 'expense',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFEBE0FF),
appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  leading: Padding(
    padding: const EdgeInsets.all(8.0),
    child: GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back_ios_outlined, size: 18, color: Colors.black),
      ),
    ),
  ),
        title: const Text("Budget", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocListener<BudgetBloc, BudgetStateBase>(
        listener: (context, state) {
          if (state is BudgetActionSuccess) {
            Navigator.pop(context);
          } else if (state is BudgetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: BudgetForm(
              isEdit: true,
              initialCategory: initialCategory,
              initialAmount: budget.budget,
              initialAlertPercentage: budget.alertPercentage,
              initialMonth: budget.month,
              initialYear: budget.year,
              submitLabel: "Set",
              onCancel: () => Navigator.pop(context),
              onSubmit: ({
                required category,
                required amount,
                required alertPercentage,
                required month,
                required year,
              }) {
                context.read<BudgetBloc>().add(
                      UpdateBudgetRequested(
                        id: budget.id,
                        categoryId: category.id,
                        amount: amount,
                        alertPercentage: alertPercentage,
                        month: budget.month,
                        year: budget.year,
                      ),
                    );
              },
            ),
          ),
        ),
      ),
    );
  }
}