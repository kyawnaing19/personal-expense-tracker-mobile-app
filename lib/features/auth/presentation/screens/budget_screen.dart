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
  final String? highlightCategoryId;
  const BudgetScreen({super.key, this.highlightCategoryId});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late int _month;
  late int _year;

  bool _showFilterPanel = false;

  final Map<String, GlobalKey> _itemKeys = {};
  bool _hasHandledHighlight = false;

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

  void _handleHighlightIfNeeded(List<BudgetItem> budgets) {
    if (_hasHandledHighlight) return;
    if (widget.highlightCategoryId == null) return;
    if (budgets.isEmpty) return;

    final match = budgets.where((b) => b.categoryId == widget.highlightCategoryId);
    if (match.isEmpty) return;

    _hasHandledHighlight = true;
    final target = match.first;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _itemKeys[target.id];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 400),
          alignment: 0.2,
        );
      }
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) _openMenu(target);
      });
    });
  }

  void _openMenu(BudgetItem budget) {
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double hPad = (screenWidth * 0.05).clamp(16.0, 28.0); 
    final double titleFontSize = (screenWidth * 0.043).clamp(15.0, 18.0);

    return Scaffold(
      backgroundColor: const Color(0xFFEBE0FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(11),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.black),
            ),
          ),
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
                 shape: BoxShape.circle,
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: FloatingActionButton(
          onPressed: _goToSetNewBudget,
          backgroundColor: const Color(0xFF8A4BEB),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

          if (!isLoading) _handleHighlightIfNeeded(budgets);

          return Column(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Budget Categories : $monthLabel",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: titleFontSize),
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
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: !_showFilterPanel
                    ? const SizedBox(width: double.infinity)
                    : Container(
                        margin: EdgeInsets.fromLTRB(hPad, 15, hPad, 0),
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
                            padding: EdgeInsets.fromLTRB(hPad, 15, hPad, 90),
                            itemCount: budgets.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 15),
                            itemBuilder: (context, index) {
                              final budget = budgets[index];
                              final isHighlighted = widget.highlightCategoryId != null &&
                                  budget.categoryId == widget.highlightCategoryId;

                              final key = _itemKeys.putIfAbsent(budget.id, () => GlobalKey());

                              final card = BudgetCard(
                                budget: budget,
                                onMenuTap: () => _openMenu(budget),
                              );

                              if (!isHighlighted) {
                                return KeyedSubtree(key: key, child: card);
                              }

                              return KeyedSubtree(
                                key: key,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFF8A4BEB), width: 2),
                                  ),
                                  child: card,
                                ),
                              );
                            },
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