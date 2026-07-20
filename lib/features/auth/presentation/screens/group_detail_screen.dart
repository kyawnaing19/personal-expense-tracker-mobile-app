import 'package:expense_tracker/features/auth/presentation/screens/group_expense_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/group_model.dart';
import '../../../../models/expense_model.dart';
import '../../data/expense_repository.dart';
import '../bloc/group_bloc.dart';
import '../bloc/group_event.dart';
import '../bloc/group_state.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import 'group_settings_screen.dart';
import 'create_expense_screen.dart';

const Color kGroupBg = Color(0xFFE8DEF8);
const Color kGroupPurple = Color(0xFF6200EE);

class GroupDetailScreen extends StatefulWidget {
  final GroupModel group;
  const GroupDetailScreen({Key? key, required this.group}) : super(key: key);

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late GroupModel _group;
  late final ExpenseBloc _expenseBloc;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    _expenseBloc = ExpenseBloc(ExpenseRepository());
    context.read<GroupBloc>().add(LoadGroupDetail(id: _group.id));
    _expenseBloc.add(LoadGroupExpenses(groupId: _group.id));
  }

  @override
  void dispose() {
    _expenseBloc.close();
    super.dispose();
  }

  void _refresh() {
    context.read<GroupBloc>().add(LoadGroupDetail(id: _group.id));
    _expenseBloc.add(LoadGroupExpenses(groupId: _group.id));
  }

  Future<void> _openCreateExpense() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider<ExpenseBloc>.value(
          value: _expenseBloc,
          child: CreateExpenseScreen(group: _group),
        ),
      ),
    );
  }

  Future<void> _openInviteChoiceSheet() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Icon(Icons.person_add_alt_1_outlined,
                        color: kGroupPurple, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Invite Members',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Invite friends to join and split expenses together.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12.5),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _openGenerateInviteCode();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGroupPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Generate Invite Code',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text('Or', style: TextStyle(color: Colors.grey[500])),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _openAddMembers();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGroupPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const Text('Add members',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openGenerateInviteCode() async {
    await showDialog(
      context: context,
      builder: (_) => _GenerateInviteCodeDialog(groupId: _group.id),
    );
  }

  Future<void> _openAddMembers() async {
    await showDialog(
      context: context,
      builder: (_) => _AddMembersDialog(groupId: _group.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExpenseBloc>.value(
      value: _expenseBloc,
      child: Scaffold(
      backgroundColor: kGroupBg,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kGroupPurple,
        shape: const CircleBorder(),
        onPressed: _openCreateExpense,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: BlocConsumer<GroupBloc, GroupStateBase>(
          listener: (context, state) {
            if (state is GroupDetailLoaded && state.group.id == _group.id) {
              setState(() => _group = state.group);
            } else if (state is MemberActionSuccess &&
                state.group.id == _group.id) {
              setState(() => _group = state.group);
            } else if (state is JoinCodeGenerated &&
                state.group.id == _group.id) {
              setState(() => _group = state.group);
            } else if (state is GroupError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RoundIconButton(
                        icon: Icons.arrow_back_ios_outlined,
                        onTap: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Group Expenses',
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          _RoundIconButton(
                            icon: Icons.person_add_alt_1_outlined,
                            onTap: _openInviteChoiceSheet,
                          ),
                          const SizedBox(width: 8),
                          _RoundIconButton(
                            icon: Icons.settings_outlined,
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      GroupSettingsScreen(group: _group),
                                ),
                              );
                              if (result == 'deleted' && context.mounted) {
                                Navigator.pop(context);
                              } else {
                                _refresh();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kGroupBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.groups_outlined,
                              color: kGroupPurple),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _group.name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Created by ${_group.creatorName}',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Expense Transactions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: BlocConsumer<ExpenseBloc, ExpenseStateBase>(
                      bloc: _expenseBloc,
                      listener: (context, expenseState) {
                        if (expenseState is ExpenseError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Expense list load error: ${expenseState.message}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      builder: (context, expenseState) {
                        if (expenseState is ExpenseListLoading ||
                            expenseState is ExpenseInitial) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (expenseState is ExpenseListLoaded &&
                            expenseState.expenses.isNotEmpty) {
                          return ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: expenseState.expenses.length,
                            // ignore: unnecessary_underscores
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, i) {
  final exp = expenseState.expenses[i];
  return GestureDetector(
    onTap: () async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider<ExpenseBloc>.value(
            value: _expenseBloc,
            child: GroupExpenseDetailScreen(
              expenseId: exp.id,
              groupId: _group.id,
              group: _group, 
            ),
          ),
        ),
      );
       _refresh(); 
    },
    child: _ExpenseCard(expense: exp),
  );
},
                          );
                        }
                        return Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long_outlined,
                                    size: 36, color: Colors.grey[400]),
                                const SizedBox(height: 10),
                                Text(
                                  'No expenses or group members yet. Start\nadding expenses to track balance.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey[500], fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      ),
    );
  }
}

const List<Color> _kAvatarColors = [
  Color(0xFF6200EE), // purple
  Color(0xFF9B59B6),
  Color(0xFF8E44AD),
  Color(0xFF3949AB),
];

Color _avatarColorFor(String seed) {
  if (seed.isEmpty) return _kAvatarColors[0];
  final idx = seed.codeUnitAt(0) % _kAvatarColors.length;
  return _kAvatarColors[idx];
}

class _ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  const _ExpenseCard({required this.expense});

  String _formatNumber(int n) {
    final s = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _formatTime(DateTime? d) {
    if (d == null) return '';
    final local = d.toLocal(); 
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    final ss = local.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final payerName = expense.paidBy?.name ?? '';
    final participants = expense.participants;
    final visible = participants.take(3).toList();
    final extra = participants.length - visible.length;
    final hasExtra = extra > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _avatarColorFor(payerName),
            child: Text(
              payerName.isNotEmpty ? payerName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.description.isNotEmpty
                    ? expense.description
                    : '(no description)',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  '${_formatDate(expense.expenseDate)}   ${_formatTime(expense.createdAt)}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_formatNumber(expense.amount),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              SizedBox(
                height: 24,
  width: 24.0 + 16.0 * (visible.length - 1 + (extra > 0 ? 1 : 0)).clamp(0, 3),
  child: Stack(
    clipBehavior: Clip.none,
                  children: [
                    if (hasExtra)
                      Positioned(
                        right: 0,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.grey[400],
                          child: Text('+$extra',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 9)),
                        ),
                      ),
                    for (int i = 0; i < visible.length; i++)
                      Positioned(
                        right: (hasExtra ? i + 1 : i) * 16.0,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: _avatarColorFor(visible[i].name),
                          child: Text(
                            visible[i].initial,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenerateInviteCodeDialog extends StatefulWidget {
  final String groupId;
  const _GenerateInviteCodeDialog({required this.groupId});

  @override
  State<_GenerateInviteCodeDialog> createState() =>
      _GenerateInviteCodeDialogState();
}

class _GenerateInviteCodeDialogState
    extends State<_GenerateInviteCodeDialog> {
  @override
  void initState() {
    super.initState();
    context
        .read<GroupBloc>()
        .add(GenerateJoinCodeRequested(groupId: widget.groupId));
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite code copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: BlocBuilder<GroupBloc, GroupStateBase>(
        builder: (context, state) {
          String? code;
          bool isLoading = state is GroupLoading;
          if (state is JoinCodeGenerated && state.group.id == widget.groupId) {
            code = state.group.joinCode;
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Group Invite Code',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Share this code so friends can join',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12.5),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: kGroupBg.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isLoading
                      ? const Center(
                          child: SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              code ?? '------',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: kGroupPurple,
                                letterSpacing: 3,
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () {
                                context.read<GroupBloc>().add(
                                    GenerateJoinCodeRequested(
                                        groupId: widget.groupId));
                              },
                              child: const Icon(Icons.refresh,
                                  color: kGroupPurple, size: 20),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: code == null ? null : () => _copyCode(code!),
                              child: const Icon(Icons.copy,
                                  color: kGroupPurple, size: 18),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Members enter this code in Join Group to join the group',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11.5),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGroupPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child:
                        const Text('Done', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


class _AddMembersDialog extends StatefulWidget {
  final String groupId;
  const _AddMembersDialog({required this.groupId});

  @override
  State<_AddMembersDialog> createState() => _AddMembersDialogState();
}

class _AddMembersDialogState extends State<_AddMembersDialog> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a valid Gmail account.')),
      );
      return;
    }
    context
        .read<GroupBloc>()
        .add(AddMemberRequested(groupId: widget.groupId, email: email));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: BlocConsumer<GroupBloc, GroupStateBase>(
        listener: (context, state) {
          if (state is MemberActionSuccess &&
              state.group.id == widget.groupId) {
            Navigator.pop(context);
          } else if (state is GroupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is GroupLoading;
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Members',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _emailController,
                  enabled: !isSubmitting,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'friend@gmail.com',
                    filled: true,
                    fillColor: kGroupBg.withOpacity(0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            isSubmitting ? null : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.black87)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGroupPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Add',
                                style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
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