import 'package:expense_tracker/features/auth/presentation/bloc/balance_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/balance_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/balance_state.dart';
import 'package:expense_tracker/models/balance_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const Color kGroupBg = Color(0xFFE8DEF8);
const Color kGroupPurple = Color(0xFF6200EE);

String _formatNumber(int n) {
  final isNeg = n < 0;
  final s = n.abs().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
    buffer.write(s[i]);
  }
  return (isNeg ? '-' : '') + buffer.toString();
}

enum _BalanceTab { toReceive, toPay }

class MemberBalanceDetailScreen extends StatefulWidget {
  final String groupId;
  final MemberBalanceModel member;
  const MemberBalanceDetailScreen({
    Key? key,
    required this.groupId,
    required this.member,
  }) : super(key: key);

  @override
  State<MemberBalanceDetailScreen> createState() =>
      _MemberBalanceDetailScreenState();
}

class _MemberBalanceDetailScreenState
    extends State<MemberBalanceDetailScreen> {
  _BalanceTab _tab = _BalanceTab.toReceive;

  @override
  void initState() {
    super.initState();
    context.read<BalanceBloc>().add(LoadMemberBalanceDetail(
          groupId: widget.groupId,
          userId: widget.member.userId,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGroupBg,
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
                  Expanded(
                    child: Center(
                      child: Text(
                        "${widget.member.name}'s Balance",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<BalanceBloc, BalanceStateBase>(
                  builder: (context, state) {
                    if (state is BalanceDetailLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is BalanceError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is BalanceDetailLoaded &&
                        state.userId == widget.member.userId) {
                      final detail = state.detail;
                      final items = _tab == _BalanceTab.toReceive
                          ? detail.owedByOthers
                          : detail.owedToOthers;
                      final totalAmount = _tab == _BalanceTab.toReceive
                          ? detail.totalToReceive
                          : detail.totalToPay;

                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _TotalCard(
                              member: widget.member,
                              tab: _tab,
                              totalAmount: totalAmount,
                            ),
                            const SizedBox(height: 16),
                            _TabToggle(
                              tab: _tab,
                              onChanged: (t) => setState(() => _tab = t),
                            ),
                            const SizedBox(height: 16),
                            if (items.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: Text(
                                    _tab == _BalanceTab.toReceive
                                        ? 'Nothing to receive'
                                        : 'Nothing to pay',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  return _tab == _BalanceTab.toReceive
                                      ? _ReceivableCard(item: item)
                                      : _PayableCard(item: item);
                                },
                              ),
                          ],
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

class _TotalCard extends StatelessWidget {
  final MemberBalanceModel member;
  final _BalanceTab tab;
  final int totalAmount;
  const _TotalCard(
      {required this.member, required this.tab, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    final isReceive = tab == _BalanceTab.toReceive;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: kGroupPurple,
            backgroundImage:
                (member.avatar != null && member.avatar!.isNotEmpty)
                    ? NetworkImage(member.avatar!)
                    : null,
            child: (member.avatar == null || member.avatar!.isEmpty)
                ? Text(member.initial,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold))
                : null,
          ),
          const SizedBox(height: 14),
          Text(
            isReceive ? 'TOTAL TO RECEIVE' : 'TOTAL TO PAY',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatNumber(totalAmount),
            style: TextStyle(
              color: isReceive ? Colors.green : Colors.red,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabToggle extends StatelessWidget {
  final _BalanceTab tab;
  final ValueChanged<_BalanceTab> onChanged;
  const _TabToggle({required this.tab, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
     // padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'To Receive',
              selected: tab == _BalanceTab.toReceive,
              onTap: () => onChanged(_BalanceTab.toReceive),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'To Pay',
              selected: tab == _BalanceTab.toPay,
              onTap: () => onChanged(_BalanceTab.toPay),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? kGroupPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
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

class _ReceivableCard extends StatelessWidget {
  final BalanceSplitItem item;
  const _ReceivableCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.expense,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 2),
          Text('Owed by ${item.personName}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AmountColumn(label: 'Amount', value: item.amountOwed),
              _AmountColumn(label: 'Paid', value: item.amountPaid),
              _AmountColumn(
                label: 'Remaining',
                value: item.remaining,
                valueText: '+${_formatNumber(item.remaining)}',
                valueColor: Colors.green,
                alignEnd: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: item.progress,
                    minHeight: 8,
                    backgroundColor: kGroupBg,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('${item.progressPercent}%',
                  style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayableCard extends StatelessWidget {
  final BalanceSplitItem item;
  const _PayableCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(item.expense,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Remaining',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  Text(_formatNumber(item.remaining),
                      style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text('Owed to ${item.personName}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AmountColumn(label: 'Owed Amount', value: item.amountOwed),
              _AmountColumn(
                label: 'Paid',
                value: item.amountPaid,
                valueColor: Colors.green,
                alignEnd: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountColumn extends StatelessWidget {
  final String label;
  final int value;
  final String? valueText;
  final Color? valueColor;
  final bool alignEnd;
  const _AmountColumn({
    required this.label,
    required this.value,
    this.valueText,
    this.valueColor,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          valueText ?? _formatNumber(value),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
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