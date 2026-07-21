import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/models/category_model.dart';
import 'package:expense_tracker/models/recurring_transaction_model.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/category_state.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/recurring_transaction_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/recurring_transaction_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/recurring_transaction_state.dart';
import 'package:expense_tracker/features/auth/data/recurring_transaction_repository.dart';
import 'add_recurring_transaction_screen.dart';

class RecurringTransactionsScreen extends StatefulWidget {
  const RecurringTransactionsScreen({Key? key}) : super(key: key);

  @override
  State<RecurringTransactionsScreen> createState() => _RecurringTransactionsScreenState();
}

class _RecurringTransactionsScreenState extends State<RecurringTransactionsScreen> {
  final Color primaryPurple = const Color(0xFF7F3DFF);
  final Color lightPurpleBg = const Color(0xFFEEE5FF);

  String _selectedFilter = 'All';
  CategoryItem? _selectedFilterCategory;
  final RecurringTransactionRepository _repository = RecurringTransactionRepository();
  List<RecurringTransactionItem> _allRecurringTransactions = [];

  @override
  void initState() {
    super.initState();
    context.read<RecurringTransactionBloc>().add(LoadRecurringTransactions());
    _loadCategoryOptions();
  }

  Future<void> _loadCategoryOptions() async {
    final all = await _repository.getRecurringTransactions();
    if (mounted) setState(() => _allRecurringTransactions = all);
  }

  void _reload() {
    context.read<RecurringTransactionBloc>().add(
          LoadRecurringTransactions(
            type: _selectedFilter == 'All' ? null : _selectedFilter.toLowerCase(),
            categoryId: _selectedFilterCategory?.id,
          ),
        );
    _loadCategoryOptions();
  }

  void _applyTypeFilter(String tab) {
    setState(() {
      _selectedFilter = tab;
      if (_selectedFilterCategory != null && tab != 'All' && _selectedFilterCategory!.type.toLowerCase() != tab.toLowerCase()) {
        _selectedFilterCategory = null;
      }
    });
    _reload();
  }

  void _showCategoryFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
      builder: (context) {
        return BlocBuilder<CategoryBloc, CategoryStateBase>(
          builder: (context, state) {
            List<CategoryItem> available = [];
            if (state is CategoryLoaded) {
              final usedCategoryIds = _allRecurringTransactions.map((t) => t.categoryId).toSet();
              available = state.categories.where((c) => usedCategoryIds.contains(c.id)).toList();
              if (_selectedFilter != 'All') {
                available = available.where((c) => c.type.toLowerCase() == _selectedFilter.toLowerCase()).toList();
              }
            }

            return Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 24),
                      const Text('Select Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                      IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: available.isEmpty
                        ? const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('No categories available for this type', style: TextStyle(color: Colors.grey)))
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount = constraints.maxWidth >= 600 ? 5 : (constraints.maxWidth >= 400 ? 4 : 3);
                              return GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: available.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, mainAxisSpacing: 20, crossAxisSpacing: 10, childAspectRatio: 0.8),
                                itemBuilder: (context, index) {
                                  final category = available[index];
                                  final isSelected = _selectedFilterCategory?.id == category.id;
                                  return InkWell(
                                    onTap: () {
                                      setState(() => _selectedFilterCategory = isSelected ? null : category);
                                      Navigator.pop(context);
                                      _reload();
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(shape: BoxShape.circle, border: isSelected ? Border.all(color: primaryPurple, width: 2.5) : null),
                                          child: CircleAvatar(radius: 26, backgroundColor: category.color, child: Icon(category.icon, color: Colors.white, size: 24)),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(category.name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: isSelected ? primaryPurple : const Color(0xFF1F2937), fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 13)),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(RecurringTransactionItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Remove this recurring transaction?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 12),
              const Text(
                'This recurring transaction will be removed and will no longer repeat, are you sure?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, false),
                      //   style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      //   child: const Text('No', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      // ),
style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryPurple, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Text('No', style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold)),
                      ),
                      
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                        child: const Text('Yes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true && mounted) {
      context.read<RecurringTransactionBloc>().add(DeleteRecurringTransactionRequested(item.id));
    }
  }

  Future<void> _goToAddOrEdit({RecurringTransactionItem? item}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddRecurringTransactionScreen(existing: item)),
    );
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 340 ? 12.0 : (screenWidth >= 600 ? 32.0 : 16.0);

    return Scaffold(
      backgroundColor: const Color(0xFFEDE7F6),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: FloatingActionButton(
          onPressed: () => _goToAddOrEdit(),
          backgroundColor: primaryPurple,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<RecurringTransactionBloc, RecurringTransactionStateBase>(
          listener: (context, state) {
            if (state is RecurringTransactionActionSuccess) _reload();
          },
          builder: (context, state) {
            List<RecurringTransactionItem> items = [];
            bool isLoading = state is RecurringTransactionLoading;
            if (state is RecurringTransactionLoaded) items = state.transactions;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildTopHeader(),
                      const SizedBox(height: 16),
                      _buildFilterRow(),
                      const SizedBox(height: 16),
                      Expanded(
                        child: isLoading
                            ? Center(child: CircularProgressIndicator(color: primaryPurple))
                            : state is RecurringTransactionError
                                ? Center(child: Text('Error: ${state.message}'))
                                : items.isEmpty
                                    ? _buildEmptyState()
                                    : ListView.separated(
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: items.length,
                                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                                        itemBuilder: (context, index) => _buildRecurringCard(items[index]),
                                      ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.description_outlined, size: 72, color: Colors.black.withOpacity(0.4)),
          const SizedBox(height: 12),
          const Text('No records', style: TextStyle(color: Colors.black54, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.arrow_back_ios_outlined, size: 20, color: Colors.black)),
        ),
        const Flexible(
          child: Text('Recurring Transactions', textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        ),
        const SizedBox(width: 36),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row( 
              children: ['All', 'Expense', 'Income'].map((tab) {
                bool isSelected = _selectedFilter == tab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _applyTypeFilter(tab),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(color: isSelected ? primaryPurple : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                      child: Text(tab, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.grey)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 7),
        GestureDetector(
          onTap: _showCategoryFilterSheet,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: _selectedFilterCategory != null ? primaryPurple : Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.filter_alt_outlined, color: _selectedFilterCategory != null ? Colors.white : Colors.black54, size: 20),
          ),
        ),
      ],
    );
  }

  DateTime _nextDisplayDate(RecurringTransactionItem item) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    DateTime step(DateTime d) {
      switch (item.frequency) {
        case 'daily':
          return d.add(const Duration(days: 1));
        case 'weekly':
          return d.add(const Duration(days: 7));
        case 'monthly':
        default:
          return DateTime(d.year, d.month + 1, d.day);
      }
    }

    DateTime date = item.startDate;
    while (!date.isAfter(todayOnly)) {
      date = step(date);
    }
    return date;
  }

  Widget _buildRecurringCard(RecurringTransactionItem item) {
    final formatter = NumberFormat('#,##0');
    final categoryState = context.read<CategoryBloc>().state;
    String categoryName = 'Unknown';
    IconData categoryIcon = Icons.receipt_long_outlined;
    Color categoryColor = Colors.indigo;
    if (categoryState is CategoryLoaded) {
      final match = categoryState.categories.firstWhere(
        (c) => c.id == item.categoryId,
        orElse: () => CategoryItem(id: '', name: 'Unknown', icon: Icons.receipt_long_outlined, color: Colors.indigo, type: item.type),
      );
      categoryName = match.name;
      categoryIcon = match.icon;
      categoryColor = match.color;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          CircleAvatar(radius: 22, backgroundColor: categoryColor, child: Icon(categoryIcon, color: Colors.white, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(categoryName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.event_repeat, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Flexible(child: Text(item.frequencyLabel, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 12))),
                ]),
                const SizedBox(height: 2),
                Text('Next: ${DateFormat('MMM d, yyyy').format(_nextDisplayDate(item))}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(formatter.format(item.amount), maxLines: 1, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert, size: 20, color: Colors.black45),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _goToAddOrEdit(item: item);
                    } else if (value == 'delete') {
                      _confirmDelete(item);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}