import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/expense_split_repository.dart';
import '../bloc/settle_debt_bloc.dart';
import '../bloc/settle_debt_event.dart';
import '../bloc/settle_debt_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../../../../models/expense_split_model.dart';

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

class SettleDebtScreen extends StatelessWidget {
  const SettleDebtScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettleDebtBloc(ExpenseSplitRepository())..add(LoadMySplits()),
      child: const _SettleDebtView(),
    );
  }
}

class _SettleDebtView extends StatelessWidget {
  const _SettleDebtView();

  String _currentUserName(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user['name'] ?? 'Me';
    }
    return 'Me';
  }

  @override
  Widget build(BuildContext context) {
    final myName = _currentUserName(context);

    return Scaffold(
      backgroundColor: kGroupBg,
      appBar: AppBar(
        backgroundColor: kGroupBg,
        elevation: 0,
        centerTitle: true,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: _RoundedBackButton(),
        ),
        leadingWidth: 56,
        title: const Text(
          'Settle Debt',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
      body: BlocConsumer<SettleDebtBloc, SettleDebtStateBase>(
        listener: (context, state) {
          if (state is SettleDebtError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is ClaimPaymentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment claimed. Waiting for confirmation.')),
            );
          }
        },
        builder: (context, state) {
          if (state is SettleDebtLoading || state is SettleDebtInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          List<ExpenseSplitModel> splits = [];
          Set<String> pendingIds = {};
          if (state is SettleDebtLoaded) {
            splits = state.splits;
            pendingIds = state.pendingClaimSplitIds;
          } else if (state is ClaimPaymentSuccess) {
            splits = state.splits;
            pendingIds = state.pendingClaimSplitIds;
          }

          if (splits.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<SettleDebtBloc>().add(LoadMySplits()),
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('You have no outstanding debts 🎉')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<SettleDebtBloc>().add(LoadMySplits()),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: splits.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (ctx, i) {
  final split = splits[i];
  final isPending = pendingIds.contains(split.id) || split.hasPendingClaim;
  return _SettleDebtCard(
    split: split,
    isPending: isPending,
    onSettleNow: () => _openPayAmountDialog(
      context,
      split: split,
      myName: myName,
    ),
  );
},
            ),
          );
        },
      ),
    );
  }

  void _openPayAmountDialog(
    BuildContext screenContext, {
    required ExpenseSplitModel split,
    required String myName,
  }) {
    final bloc = screenContext.read<SettleDebtBloc>();
    Navigator.push(
      screenContext,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: _PayAmountScreen(
            split: split,
            myName: myName,
          ),
        ),
      ),
    );
  }
}

class _SettleDebtCard extends StatelessWidget {
  final ExpenseSplitModel split;
  final bool isPending;
  final VoidCallback onSettleNow;

  const _SettleDebtCard({
    required this.split,
    required this.isPending,
    required this.onSettleNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kGroupBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.groups_outlined, color: Colors.black54),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      split.groupTitle.isNotEmpty ? split.groupTitle : 'Group Expense',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    if (split.description.isNotEmpty)
                      Text('Description : ${split.description}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    if (split.owedToName.isNotEmpty)
                      Text('Owed to ${split.owedToName}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    const SizedBox(height: 6),
                    Text('Amount  Owed : ${_formatNumber(split.amountOwed)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const SizedBox(height: 2),
                    Text('Amount Paid : ${_formatNumber(split.amountPaid)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress (${split.progressPercent}%)',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text(
                '${_formatNumber(split.amountPaid)} / ${_formatNumber(split.amountOwed)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: split.progress,
              minHeight: 8,
              backgroundColor: kGroupBg,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Remaining', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  Text(
                    _formatNumber(split.remainingAmount),
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            if (isPending)
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: kGroupPurple.withOpacity(0.4)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.sync_alt_outlined, size: 16, color: kGroupPurple),
        const SizedBox(width: 6),
        Text('Pending',
            style: TextStyle(
                color: Colors.grey[700], fontWeight: FontWeight.w600)),
      ],
    ),
  )
else
                ElevatedButton(
                  onPressed: onSettleNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGroupPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Settle Now'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundedBackButton extends StatelessWidget {
  const _RoundedBackButton();

  @override

Widget build(BuildContext context) {
  return Material(
    color: Colors.white,
    shape: const CircleBorder(),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => Navigator.pop(context),
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Icon(Icons.arrow_back_ios_outlined, color: Colors.black87, size: 16),
      ),
    ),
  );
}
}
class _PayAmountScreen extends StatefulWidget {
  final ExpenseSplitModel split;
  final String myName;

  const _PayAmountScreen({required this.split, required this.myName});

  @override
  State<_PayAmountScreen> createState() => _PayAmountScreenState();
}

class _PayAmountScreenState extends State<_PayAmountScreen> {
  final TextEditingController _amountController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _initial(String name) => name.isNotEmpty ? name[0].toUpperCase() : '?';

  void _onDone() {
    final raw = _amountController.text.replaceAll(',', '').trim();
    final amount = int.tryParse(raw);

    if (amount == null || amount <= 0) {
      setState(() => _errorText = 'Enter a valid amount');
      return;
    }
    if (amount > widget.split.remainingAmount) {
      setState(() => _errorText = 'Amount exceeds remaining balance');
      return;
    }

    context.read<SettleDebtBloc>().add(
          ClaimPaymentRequested(splitId: widget.split.id, amount: amount),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGroupBg,
      appBar: AppBar(
        backgroundColor: kGroupBg,
        elevation: 0,
        centerTitle: true,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: _RoundedBackButton(),
        ),
        leadingWidth: 56,
        title: const Text(
          'Settle Debt',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: kGroupBg,
                        child: Text(_initial(widget.myName),
                            style: const TextStyle(
                                color: kGroupPurple, fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      const SizedBox(height: 6),
                      Text(widget.myName, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kGroupPurple.withOpacity(0.08),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.keyboard_double_arrow_right,
                        color: kGroupPurple, size: 20),
                  ),
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.blue[50],
                        child: Text(_initial(widget.split.owedToName),
                            style: const TextStyle(
                                color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      const SizedBox(height: 6),
                      Text(widget.split.owedToName, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Pay Amount',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  errorText: _errorText,
                  hintText: '0',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                onChanged: (_) {
                  if (_errorText != null) setState(() => _errorText = null);
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Colors.black87)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onDone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGroupPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}