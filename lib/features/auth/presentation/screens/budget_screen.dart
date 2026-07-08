import 'package:expense_tracker/features/auth/presentation/screens/budget_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/budget_model.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';
import '../widgets/budget_card.dart';
import 'budget_utils.dart';
import 'set_new_budget_screen.dart';
import 'edit_budget_screen.dart';
import 'remove_budget_dialog.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late int _month;
  late int _year;

  // Single source of truth for whether the month/year filter box is
  // visible. It starts closed and is ONLY ever flipped by the filter
  // icon's onTap below — nothing else in this screen should set it.
  bool _showFilterPanel = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = now.month;
    _year = now.year;
    _reload();
  }

  void _reload() {
    context.read<BudgetBloc>().add(LoadBudgets(month: _month, year: _year));
  }

  void _toggleFilterPanel() {
    setState(() => _showFilterPanel = !_showFilterPanel);
  }

  void _closeFilterPanel() {
    if (_showFilterPanel) {
      setState(() => _showFilterPanel = false);
    }
  }

  void _onFilterChanged({int? month, int? year}) {
    setState(() {
      if (month != null) _month = month;
      if (year != null) _year = year;
    });
    _reload();
  }

  void _openMenu(BudgetItem budget) {
    // Close the filter box before opening the bottom sheet so the filter
    // icon can't be left looking "active" while its panel is hidden behind
    // other content.
    _closeFilterPanel();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => BudgetDetailsScreen(
        budget: budget,
        onEditTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditBudgetScreen(budget: budget)),
          );
          _reload();
        },
        onRemoveTap: () {
          showRemoveBudgetConfirmation(
            context,
            onConfirm: () {
              context.read<BudgetBloc>().add(
                    DeleteBudgetRequested(id: budget.id, month: _month, year: _year),
                  );
            },
          );
        },
      ),
    );
  }

  Future<void> _goToSetNewBudget() async {
    _closeFilterPanel();
    final now = DateTime.now();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SetNewBudgetScreen(month: now.month, year: now.year),
      ),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final String monthLabel = "${kMonthNamesShort[_month - 1]} $_year";
    final years = filterableYears(DateTime.now().year);

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: _toggleFilterPanel,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _showFilterPanel ? const Color(0xFF8A4BEB) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.filter_alt_outlined,
                  size: 20,
                  color: _showFilterPanel ? Colors.white : const Color(0xFF8A4BEB),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<BudgetBloc, BudgetStateBase>(
        listener: (context, state) {
          if (state is BudgetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final bool isLoading = state is BudgetLoading;
          final List<BudgetItem> budgets = state is BudgetLoaded ? state.budgets : [];

          return Column(
            children: [
              // Header card
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Budget Categories : $monthLabel",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (!isLoading && budgets.isEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        "You haven't set a budget for this month yet. Enter a budget amount and select your preferred alert threshold to receive notifications when spending gets close.",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),

              // Filter panel (month/year picker) — only ever rendered when
              // _showFilterPanel is true, which only the filter icon sets.
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: !_showFilterPanel
                    ? const SizedBox(width: double.infinity)
                    : Container(
                        margin: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Choose a month and year to see your monthly budget.",
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Text("Month", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                                const Spacer(),
                                _filterDropdown<int>(
                                  value: _month,
                                  items: List.generate(12, (i) => i + 1),
                                  labelBuilder: (m) => kMonthNamesFull[m - 1],
                                  onChanged: (v) => _onFilterChanged(month: v),
                                ),
                                const SizedBox(width: 10),
                                _filterDropdown<int>(
                                  value: _year,
                                  items: years,
                                  labelBuilder: (y) => y.toString(),
                                  onChanged: (v) => _onFilterChanged(year: v),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),

              // Body
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF8A4BEB)))
                    : budgets.isEmpty
                        ? const SizedBox.shrink()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                            itemCount: budgets.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 15),
                            itemBuilder: (context, index) {
                              final budget = budgets[index];
                              return BudgetCard(
                                budget: budget,
                                onMenuTap: () => _openMenu(budget),
                              );
                            },
                          ),
              ),

              // Set New Budget Button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton.icon(
                  onPressed: _goToSetNewBudget,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Set New Budget", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A4BEB),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterDropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required void Function(T?) onChanged,
  }) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: const Color(0xFFE2D9F3), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items.map((item) => DropdownMenuItem<T>(value: item, child: Text(labelBuilder(item)))).toList(),
          onChanged: onChanged,
          style: const TextStyle(color: Colors.black, fontSize: 14),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF8A4BEB)),
        ),
      ),
    );
  }
}