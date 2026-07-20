import 'package:expense_tracker/features/auth/presentation/bloc/balance_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/balance_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/balance_state.dart';
import 'package:expense_tracker/models/balance_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const Color kSettleBg = Color(0xFFE8DEF8);
const Color kSettlePurple = Color(0xFF6200EE);

class SettlementHistoryScreen extends StatefulWidget {
  final String groupId;
  final MemberBalanceModel member;
  const SettlementHistoryScreen({
    Key? key,
    required this.groupId,
    required this.member,
  }) : super(key: key);

  @override
  State<SettlementHistoryScreen> createState() =>
      _SettlementHistoryScreenState();
}

class _SettlementHistoryScreenState extends State<SettlementHistoryScreen> {
  bool _showReceived = true;

  @override
  void initState() {
    super.initState();
    context.read<BalanceBloc>().add(LoadSettlementHistory(
          groupId: widget.groupId,
          userId: widget.member.userId,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSettleBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.arrow_back_ios_outlined,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Settlement History',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 20),
              _TabToggle(
                showReceived: _showReceived,
                onChanged: (v) => setState(() => _showReceived = v),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<BalanceBloc, BalanceStateBase>(
                  builder: (context, state) {
                    if (state is SettlementHistoryLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is BalanceError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is SettlementHistoryLoaded &&
                        state.userId == widget.member.userId) {
                      final items = _showReceived
                          ? state.history.receivedByOthers
                          : state.history.paidToOthers;
                      if (items.isEmpty) {
                        return const Center(child: Text('No history yet'));
                      }
                      return ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 14),
                        itemBuilder: (_, index) => _HistoryCard(
                          memberName: widget.member.name,
                          item: items[index],
                          isReceived: _showReceived,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabToggle extends StatelessWidget {
  final bool showReceived;
  final ValueChanged<bool> onChanged;
  const _TabToggle({required this.showReceived, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      //padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(child: _tabButton('Received by others', true)),
          Expanded(child: _tabButton('Paid to others', false)),
        ],
      ),
    );
  }

  Widget _tabButton(String label, bool value) {
    final selected = showReceived == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? kSettlePurple : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String memberName;
  final SettlementHistoryItem item;
  final bool isReceived;

  const _HistoryCard({
    required this.memberName,
    required this.item,
    required this.isReceived,
  });

  String _formatAmount(int n) {
    final s = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = _months[local.month - 1];
    final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'pm' : 'am';
    return '$day-$month-${local.year} $hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final sentence = isReceived
        ? '$memberName received  ${_formatAmount(item.amount)} Ks from ${item.otherPartyName}.'
        : '$memberName paid ${item.otherPartyName} ${_formatAmount(item.amount)} Ks .';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFDFF5E1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.payments_rounded,
                color: Color(0xFF2E9E4F), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sentence,
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.expense,
                    style: TextStyle(
                        fontSize: 11.5,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDate(item.confirmedAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
      ),
    );
  }
}