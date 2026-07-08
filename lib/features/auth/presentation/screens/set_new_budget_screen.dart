import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';
import '../widgets/budget_form.dart';
import 'budget_utils.dart';

class SetNewBudgetScreen extends StatelessWidget {
  final int month;
  final int year;

  const SetNewBudgetScreen({super.key, required this.month, required this.year});

  @override
  Widget build(BuildContext context) {
    final String monthLabel = "${kMonthNamesShort[month - 1]} $year";

    return Scaffold(
      backgroundColor: const Color(0xFFEBE0FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 20),
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Budget Categories : $monthLabel", style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text(
                        "You haven't set a budget for this month yet. Enter a budget amount and select your preferred alert threshold...",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                BudgetForm(
                  isEdit: false,
                  initialMonth: month,
                  initialYear: year,
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
                          CreateBudgetRequested(
                            categoryId: category.id,
                            amount: amount,
                            alertPercentage: alertPercentage,
                            month: month,
                            year: year,
                          ),
                        );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}