import 'package:expense_tracker/features/auth/data/balance_repository.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/balance_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/balance_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/balance_state.dart';
import 'package:expense_tracker/features/auth/presentation/screens/members_balance_detail_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/settlement_history_screen.dart';
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

class MembersBalanceScreen extends StatefulWidget {
  final String groupId;
  const MembersBalanceScreen({Key? key, required this.groupId})
      : super(key: key);

  @override
  State<MembersBalanceScreen> createState() => _MembersBalanceScreenState();
}

class _MembersBalanceScreenState extends State<MembersBalanceScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BalanceBloc>().add(LoadGroupBalance(groupId: widget.groupId));
  }

  void _openDetail(BuildContext ctx, MemberBalanceModel member) {
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => BalanceBloc(BalanceRepository()),
          child: MemberBalanceDetailScreen(
            groupId: widget.groupId,
            member: member,
          ),
        ),
      ),
    );
  }

  void _openSettlementHistory(BuildContext ctx, MemberBalanceModel member) {
  Navigator.push(
    ctx,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => BalanceBloc(BalanceRepository()),
        child: SettlementHistoryScreen(
          groupId: widget.groupId,
          member: member,
        ),
      ),
    ),
  );
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
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Members' Balance",
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    if (state is BalanceListLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is BalanceError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is BalanceListLoaded &&
                        state.groupId == widget.groupId) {
                      if (state.members.isEmpty) {
                        return const Center(child: Text('No members yet'));
                      }
                      return ListView.separated(
                        itemCount: state.members.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (itemCtx, index) {
                          return _MemberBalanceCard(
                            member: state.members[index],
                            onViewDetail: () =>
                                _openDetail(itemCtx, state.members[index]),
                            onSettlementHistory: () => _openSettlementHistory(
                                itemCtx, state.members[index]),
                          );
                        },
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

class _MemberBalanceCard extends StatelessWidget {
  final MemberBalanceModel member;
  final VoidCallback onViewDetail;
  final VoidCallback onSettlementHistory;

  const _MemberBalanceCard({
    required this.member,
    required this.onViewDetail,
    required this.onSettlementHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: kGroupPurple,
                backgroundImage:
                    (member.avatar != null && member.avatar!.isNotEmpty)
                        ? NetworkImage(member.avatar!)
                        : null,
                child: (member.avatar == null || member.avatar!.isEmpty)
                    ? Text(member.initial,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 12),
              Text(member.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recievable',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('+${_formatNumber(member.totalReceivable)}',
                      style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Payable',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('-${_formatNumber(member.totalPayable)}',
                      style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onViewDetail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGroupPurple,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('View\nBalance Detail',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onSettlementHistory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGroupBg,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Settlement\nHistory',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black87, fontSize: 12)),
                ),
              ),
            ],
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