import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/models/category_model.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/models/pending_recurring_transaction_model.dart';
import 'package:expense_tracker/features/auth/data/pending_transaction_repository.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/transaction_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/transaction_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/transaction_state.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/category_state.dart';
import 'package:expense_tracker/features/auth/presentation/screens/transaction_detail_screen.dart';
import 'record_history_screen.dart';
import 'category_screen.dart'; 
import 'dart:math' as math;

enum CategoryState { view, add, edit }

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;
  CategoryState _currentState = CategoryState.view; 
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _HomeDashboardBody(onSeeAllTransactions: _goToTransactionHistory),
      const Center(child: Text("Pie Chart / Analytics Screen", style: TextStyle(fontSize: 18))), 
      const CategoryScreen(), 
      const SizedBox.shrink(),
      const Center(child: Text("Profile Screen", style: TextStyle(fontSize: 18))), 
    ];
  }

  Future<void> _goToTransactionHistory() async {
    setState(() => _currentTabIndex = 3);
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const RecordHistoryScreen()));
    if (!mounted) return;
    setState(() {
      _currentTabIndex = 0;
      _currentState = CategoryState.view;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE7F6),
      body: SafeArea(
        child: _currentTabIndex == 3
            ? _HomeDashboardBody(onSeeAllTransactions: _goToTransactionHistory) // 🎯 Index 3 (History) က ပြန်ထွက်လာရင် Home Dashboard ကို ပြန်ပြရန်
            : IndexedStack(
                index: _currentTabIndex,
                children: _pages,
              ),
      ),
    );
  }
}

class _HomeDashboardBody extends StatefulWidget {
  final Future<void> Function() onSeeAllTransactions;
  const _HomeDashboardBody({Key? key, required this.onSeeAllTransactions}) : super(key: key);

  @override
  State<_HomeDashboardBody> createState() => _HomeDashboardBodyState();
}

class _HomeDashboardBodyState extends State<_HomeDashboardBody> {
  bool _isBalanceVisible = true;
  String _transactionFilter = 'All';

  final PendingTransactionRepository _pendingRepository = PendingTransactionRepository();
  List<PendingRecurringTransaction> _pendingAlerts = [];
  final Set<String> _processingAlertIds = {};

  final GlobalKey _upcomingAlertsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactions());
    _loadPendingAlerts();
  }

  Future<void> _loadPendingAlerts() async {
    final list = await _pendingRepository.getPendingTransactions();
    if (!mounted) return;
    setState(() => _pendingAlerts = list);
  }

  Future<void> _onRefresh() async {
    context.read<TransactionBloc>().add(LoadTransactions());
    await _loadPendingAlerts();
  }

  Future<void> _handleAlertAction(PendingRecurringTransaction item, bool accept) async {
    setState(() => _processingAlertIds.add(item.id));
    try {
      if (accept) {
        await _pendingRepository.acceptTransaction(item.id);
      } else {
        await _pendingRepository.rejectTransaction(item.id);
      }
      if (!mounted) return;
      setState(() {
        _pendingAlerts.removeWhere((e) => e.id == item.id);
        _processingAlertIds.remove(item.id);
      });
      if (accept) {
        context.read<TransactionBloc>().add(LoadTransactions());
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _processingAlertIds.remove(item.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(accept ? 'Failed to accept, please try again.' : 'Failed to reject, please try again.')),
      );
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  String _initials(String name) => name.trim().isEmpty ? 'U' : name.trim()[0].toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: _buildAppBar(),
        ),
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xFF7C3AED),
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  String userName = 'User';
                  String? userAvatar;
                  if (authState is AuthAuthenticated) {
                    userName = (authState.user['name'] ?? 'User').toString();
                    final avatar = authState.user['avatar'];
                    userAvatar = (avatar != null && avatar.toString().isNotEmpty) ? avatar.toString() : null;
                  }
                  return BlocBuilder<CategoryBloc, CategoryStateBase>(
                    builder: (context, categoryState) {
                      final List<CategoryItem> categories = categoryState is CategoryLoaded ? categoryState.categories : <CategoryItem>[];

                      return BlocConsumer<TransactionBloc, TransactionStateBase>(
                        listener: (context, state) {
                          if (state is TransactionActionSuccess) {
                            context.read<TransactionBloc>().add(LoadTransactions());
                          }
                        },
                        builder: (context, txState) {
                          final List<TransactionItem> allTransactions = txState is TransactionLoaded ? txState.transactions : [];

                          double totalIncome = 0;
                          double totalExpense = 0;
                          for (final tx in allTransactions) {
                            if (tx.type.toLowerCase() == 'income') totalIncome += tx.amount;
                            if (tx.type.toLowerCase() == 'expense') totalExpense += tx.amount;
                          }
                          final double currentBalance = totalIncome - totalExpense;
                          final bool isLoadingTransactions = txState is TransactionLoading && allTransactions.isEmpty;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTotalBalanceCard(userName, userAvatar, currentBalance, totalIncome, totalExpense),
                              const SizedBox(height: 24),
                              _buildUpcomingAlertsSection(categories),
                              const SizedBox(height: 24),
                              _buildRecentTransactionsSection(allTransactions, isLoadingTransactions, categories),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset('assets/images/logo.jpg', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 50),
            const Text("Expense Tracker", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
        GestureDetector(
          onTap: () {
            if (_pendingAlerts.isEmpty) return;
            final alertContext = _upcomingAlertsKey.currentContext;
            if (alertContext != null) {
              Scrollable.ensureVisible(alertContext, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
            }
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.notifications_none_outlined, size: 22, color: Colors.black87),
              ),
              if (_pendingAlerts.isNotEmpty)
                Positioned(
                  right: -2,
                  top: -2,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${_pendingAlerts.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalBalanceCard(String userName, String? userAvatar, double balance, double income, double expense) {
    final formatter = NumberFormat('#,##0');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9F75FF), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white24,
                backgroundImage: userAvatar != null ? NetworkImage(userAvatar) : null,
                onBackgroundImageError: userAvatar != null ? (exception, stackTrace) {} : null,
                child: userAvatar == null
                    ? Text(_initials(userName), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_greeting(), style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(userName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),       
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Text("Current Balance", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
    const SizedBox(width: 6),
    GestureDetector(
      onTap: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
      child: Icon(_isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white70, size: 16),
    )
  ],
),
const SizedBox(height: 4),
Text(
  _isBalanceVisible ? formatter.format(balance) : "•••••",
  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
),
const SizedBox(height: 20),
Container(height: 1, color: Colors.white24),
const SizedBox(height: 16),
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Expanded(
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.white,
            child: Icon(Icons.arrow_upward, size: 14, color: const Color.fromARGB(255, 25, 209, 120)),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Income", style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text(_isBalanceVisible ? formatter.format(income) : "•••••",
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    ),
    Container(width: 1, height: 30, color: Colors.white24),
    Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.white,
            child: Transform.rotate(
              angle: math.pi,
              child: const Icon(Icons.arrow_upward, size: 14, color: Colors.redAccent),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Expense", style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text(_isBalanceVisible ? formatter.format(expense) : "•••••",
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    ),
  ],
),
        ],
      ),
    );
  }

  Widget _buildUpcomingAlertsSection(List<CategoryItem> categories) {
    if (_pendingAlerts.isEmpty) return const SizedBox.shrink();

    return Column(
      key: _upcomingAlertsKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Upcoming Alerts", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 9,
              backgroundColor: const Color(0xFF7C3AED),
              child: Text('${_pendingAlerts.length}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 12),
        ..._pendingAlerts.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildAlertCard(item, categories),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertCard(PendingRecurringTransaction item, List<CategoryItem> categories) {
    final bool isIncome = item.type == 'income';
    final formatter = NumberFormat('#,##0');
    final bool isProcessing = _processingAlertIds.contains(item.id);

    // 🛠️ Fixed: previously fell back to a freshly-constructed generic
    // CategoryItem (always the same clock/receipt icon) whenever the
    // category lookup missed, so every alert card looked identical and
    // didn't match Record History. Now it falls back to a real category
    // like the transaction tiles do, and renders the same solid-circle +
    // white-icon style as Record History.
    IconData icon = Icons.receipt_long_outlined;
    Color iconColor = isIncome ? Colors.green : Colors.orange;
    if (categories.isNotEmpty) {
      final match = categories.firstWhere(
        (c) => c.id == item.categoryId,
        orElse: () => categories.first,
      );
      icon = match.icon;
      iconColor = match.color;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: isIncome ? Colors.green.shade300 : Colors.orange.shade300, width: 5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 18, backgroundColor: iconColor, child: Icon(icon, color: Colors.white, size: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(6)),
                          child: Text('REMINDER', style: TextStyle(color: Colors.purple.shade900, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isIncome ? const Color(0xFFDCFCE7) : const Color(0xFFFFE4E6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(item.type, style: TextStyle(color: isIncome ? Colors.green.shade900 : Colors.red.shade900, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.categoryName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                    Text(
                      '${formatter.format(item.amount)} MMK payment due ${DateFormat('MMM d').format(item.transactionDate)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isProcessing)
            const Align(
              alignment: Alignment.centerRight,
              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildPillButton('Accept', Colors.green, () => _handleAlertAction(item, true)),
                const SizedBox(width: 8),
                _buildPillButton('Reject', Colors.red, () => _handleAlertAction(item, false)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPillButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // 🛠️ Recent Transactions -- last 3 from the same data Record History uses,
  // filtered the same way (All / Expense / Income).
  Widget _buildRecentTransactionsSection(List<TransactionItem> allTransactions, bool isLoading, List<CategoryItem> categories) {
    List<TransactionItem> filtered = List<TransactionItem>.from(allTransactions);
    if (_transactionFilter != 'All') {
      filtered = filtered.where((tx) => tx.type.toLowerCase() == _transactionFilter.toLowerCase()).toList();
    }
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recent = filtered.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Recent Transactions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
            GestureDetector(
              onTap: widget.onSeeAllTransactions,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: const [
                    Text("See all", style: TextStyle(color: Color(0xFF7C3AED), fontSize: 12, fontWeight: FontWeight.w600)),
                    Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF7C3AED)),
                  ],
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: ['All', 'Expense', 'Income'].map((tab) {
            bool isSelected = _transactionFilter == tab;
            return GestureDetector(
              onTap: () => setState(() => _transactionFilter = tab),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF7C3AED) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tab,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.grey),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (recent.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: const Center(child: Text("No transactions found", style: TextStyle(color: Colors.grey, fontSize: 14))),
          )
        else
          ...recent.map((tx) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _buildTransactionTile(tx, categories))),
      ],
    );
  }

  Widget _buildTransactionTile(TransactionItem tx, List<CategoryItem> categories) {
    final bool isExpense = tx.type.toLowerCase() == 'expense';
    final formatter = NumberFormat('#,##0');

    String categoryName = 'Unknown';
    IconData icon = Icons.local_offer_outlined;
    Color color = Colors.indigo;
    if (categories.isNotEmpty) {
      final match = categories.firstWhere(
        (c) => c.id == tx.categoryId,
        orElse: () => categories.first,
      );
      categoryName = match.name;
      icon = match.icon;
      color = match.color;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailScreen(
              transaction: tx,
              categoryName: categoryName,
              categoryIcon: icon,
              categoryColor: color,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            // 🛠️ Fixed: switched from a tinted circle + colored icon to a
            // solid-color circle + white icon so it matches Record History.
            CircleAvatar(radius: 22, backgroundColor: color, child: Icon(icon, color: Colors.white, size: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(categoryName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(DateFormat('dd/MM  HH:mm').format(tx.createdAt.toLocal()), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isExpense ? "-${formatter.format(tx.amount)}" : "+${formatter.format(tx.amount)}",
                  style: TextStyle(color: isExpense ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                // const SizedBox(height: 4),
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                //   decoration: BoxDecoration(color: isExpense ? const Color(0xFFFFE4E6) : const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
                //   child: Text(
                //     isExpense ? "expense" : "income",
                //     style: TextStyle(color: isExpense ? Colors.red : Colors.green, fontSize: 9, fontWeight: FontWeight.bold),
                //   ),
                // ),
         const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(color: isExpense ? const Color(0xFFFFE4E6) : const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(isExpense ? Icons.arrow_downward : Icons.arrow_upward, size: 10, color: isExpense ? Colors.red : Colors.green),
                              const SizedBox(width: 2),
                              Text(tx.type, style: TextStyle(color: isExpense ? Colors.red : Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
              ],
            )
          ],
        ),
      ),
    );
  }
}