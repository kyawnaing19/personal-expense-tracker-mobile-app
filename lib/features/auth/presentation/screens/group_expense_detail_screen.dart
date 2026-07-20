import 'package:expense_tracker/core/services/current_user_service..dart';
import 'package:expense_tracker/features/auth/data/expense_repository.dart';
import 'package:expense_tracker/models/group_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/expense_model.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';

const Color kDetailBg = Color(0xFFE8DEF8);
const Color kDetailPurple = Color(0xFF6200EE);

const List<Color> _kAvatarColors = [
  Color(0xFF6200EE),
  Color(0xFF9B59B6),
  Color(0xFF8E44AD),
  Color(0xFF3949AB),
];

Color _avatarColorFor(String seed) {
  if (seed.isEmpty) return _kAvatarColors[0];
  final idx = seed.codeUnitAt(0) % _kAvatarColors.length;
  return _kAvatarColors[idx];
}

class GroupExpenseDetailScreen extends StatefulWidget {
  final String expenseId;
  final String groupId;
  final GroupModel group;
  const GroupExpenseDetailScreen({
    Key? key,
    required this.expenseId,
    required this.groupId,
    required this.group,
  }) : super(key: key);

  @override
  State<GroupExpenseDetailScreen> createState() =>
      _GroupExpenseDetailScreenState();
}

class _GroupExpenseDetailScreenState extends State<GroupExpenseDetailScreen> {
  bool _isEditing = false;
  ExpenseModel? _expense;
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  final Map<String, TextEditingController> _splitControllers = {};
  DateTime? _editDate;
  String? _editSplitType; // 'equally' | 'custom'
  bool _editIncludePayer = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(LoadExpenseDetail(expenseId: widget.expenseId));
    _loadCurrentUser();
    for (final m in widget.group.members) {
      _splitControllers[m.id] = TextEditingController()
        ..addListener(() => setState(() {}));
    }
  }

  Future<void> _loadCurrentUser() async {
    final user = await CurrentUserService.getCurrentUser();
    if (mounted) setState(() => _currentUserId = user['id']);
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    for (final c in _splitControllers.values) c.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _formatNumber(int n) {
    final s = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
  int _payerShareAmount(ExpenseModel expense) {
    if (expense.splitType == 'equally') {
      if (expense.includePayer == true) {
        return expense.participants.isNotEmpty
            ? (expense.participants.first.share ?? 0)
            : 0;
      }
      return 0;
    } else {
      final participantsSum = expense.participants
          .fold<int>(0, (sum, p) => sum + (p.share ?? 0));
      final remaining = expense.amount - participantsSum;
      return remaining < 0 ? 0 : remaining;
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _startEditing(ExpenseModel expense) {
    _descController.text = expense.description;
    _amountController.text = expense.amount.toString();
    _editDate = expense.expenseDate;
    _editSplitType = expense.splitType;
    _editIncludePayer = expense.includePayer ?? true;
    for (final m in widget.group.members) {
      if (m.id == expense.paidBy?.id) {
        _splitControllers[m.id]!.text = _payerShareAmount(expense).toString();
        continue;
      }
      final existing = expense.participants
          .where((p) => p.name == m.name) 
          .toList();
      _splitControllers[m.id]!.text =
          existing.isNotEmpty && existing.first.share != null
              ? existing.first.share.toString()
              : '';
    }
    setState(() => _isEditing = true);
  }

  int get _amount => int.tryParse(_amountController.text.trim()) ?? 0;

  int get _customSplitSum {
    int sum = 0;
    for (final m in widget.group.members) {
      sum += int.tryParse(_splitControllers[m.id]?.text.trim() ?? '') ?? 0;
    }
    return sum;
  }

  List<dynamic> get _equalEditMembers {
    final members = widget.group.members;
    return _editIncludePayer
        ? members
        : members.where((m) => m.id != _currentUserId).toList();
  }

  int get _equalEditShare {
    final totalMembers =
        _equalEditMembers.isNotEmpty ? _equalEditMembers.length : 1;
    return (_amount / totalMembers).round();
  }

  Future<void> _pickEditDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _editDate != null && _editDate!.isAfter(today)
          ? today
          : (_editDate ?? today),
      firstDate: DateTime(now.year - 5),
      lastDate: today,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kDetailPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: kDetailPurple),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _editDate = picked);
  }

  void _saveEdit(ExpenseModel expense) {
    if (_amount <= 0) {
      _showError('Put the amount correctly.');
      return;
    }
    List<ExpenseSplitInput>? splits;
    if (_editSplitType == 'custom') {
      if (_customSplitSum != _amount) {
        _showError('Please split the total amount exactly.');
        return;
      }
      splits = widget.group.members
          .map((m) => ExpenseSplitInput(
                userId: m.id,
                amountOwed:
                    int.tryParse(_splitControllers[m.id]?.text.trim() ?? '') ?? 0,
              ))
          .where((s) => s.amountOwed > 0)
          .toList();
    }

    context.read<ExpenseBloc>().add(UpdateExpenseRequested(
          expenseId: widget.expenseId,
          groupId: widget.groupId,
          amount: _amount,
          description: _descController.text.trim(),
          expenseDate: _editDate ?? expense.expenseDate,
          splitType: _editSplitType ?? expense.splitType,
          includePayer: _editSplitType == 'equally' ? _editIncludePayer : null,
          splits: splits,
        ));
  }

  Future<void> _confirmDelete(ExpenseModel expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text(
          'Delete "${expense.description.isNotEmpty ? expense.description : 'this expense'}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      context.read<ExpenseBloc>().add(
          DeleteExpenseRequested(expenseId: widget.expenseId, groupId: widget.groupId));
    }
  }

  Widget _splitTypeButton(String label, String value) {
    final selected = _editSplitType == value;
    return OutlinedButton(
      onPressed: () => setState(() => _editSplitType = value),
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? const Color.fromARGB(255, 224, 205, 252) : Colors.white,
        side: BorderSide(color: kDetailPurple.withOpacity(selected ? 1 : 0.4)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: TextStyle(color: selected ? Colors.black87 : Colors.black87)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExpenseBloc, ExpenseStateBase>(
      listener: (context, state) {
        if (state is ExpenseDetailLoaded) {
          _expense = state.expense; // cache လုပ်ထားမယ်
        } else if (state is ExpenseUpdateSuccess) {
          _expense = state.expense;
          setState(() => _isEditing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense updated')),
          );
        } else if (state is ExpenseDeleteSuccess &&
            state.expenseId == widget.expenseId) {
          Navigator.pop(context, true);
        } else if (state is ExpenseError) {
          _showError(state.message);
          setState(() => _isEditing = false); 
        }
      },
      builder: (context, state) {
        if (state is ExpenseDetailLoaded) _expense = state.expense;
        final expense = _expense; 
        final isBusy = state is ExpenseDetailLoading ||
            state is ExpenseDeleting ||
            state is ExpenseUpdating;

        return Scaffold(
          backgroundColor: kDetailBg,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      _RoundIconButton(
                        icon: Icons.arrow_back_ios_outlined,
                        onTap: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                              _isEditing ? 'Edit Expense Details' : 'Expense Details',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        expense == null
                            ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 80),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isEditing) ...[
                                _label('Description'),
                                TextField(controller: _descController,
                                    decoration: _editDecoration()),
                                const SizedBox(height: 16),
                              ] else
                                _DetailRow(label: 'Description', value: expense.description),
                              const SizedBox(height: 16),

                              if (_isEditing) ...[
                                _label('Amount'),
                                TextField(controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    decoration: _editDecoration()),
                                const SizedBox(height: 16),
                              ] else
                                _DetailRow(label: 'Amount', value: _formatNumber(expense.amount)),
                              const SizedBox(height: 16),

                              if (_isEditing) ...[
                                _label('Date'),
                                InkWell(
                                  onTap: _pickEditDate,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: kDetailPurple.withOpacity(0.4)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(_formatDate(_editDate ?? expense.expenseDate)),
                                        const Icon(Icons.calendar_today_outlined,
                                            size: 18, color: kDetailPurple),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ] else
                                _DetailRow(label: 'Date', value: _formatDate(expense.expenseDate)),
                              const SizedBox(height: 16),

                              _DetailRow(
                                label: 'Paid By',
                                valueWidget: expense.paidBy == null
                                    ? const Text('-')
                                    : _PersonChip(person: expense.paidBy!),
                              ),
                              const SizedBox(height: 16),

                              if (_isEditing) ...[
                                _label('Split Type'),
                                Row(
                                  children: [
                                    Expanded(child: _splitTypeButton('Equal', 'equally')),
                                    const SizedBox(width: 12),
                                    Expanded(child: _splitTypeButton('Custom', 'custom')),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (_editSplitType == 'equally') ...[
                                  Row(
                                    children: [
                                      Radio<bool>(value: true, groupValue: _editIncludePayer,
                                          activeColor: kDetailPurple,
                                          onChanged: (v) => setState(() => _editIncludePayer = v!)),
                                      const Text('Include Me', style: TextStyle(fontSize: 12.5)),
                                      Radio<bool>(value: false, groupValue: _editIncludePayer,
                                          activeColor: kDetailPurple,
                                          onChanged: (v) => setState(() => _editIncludePayer = v!)),
                                      const Text('Exclude Me', style: TextStyle(fontSize: 12.5)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  for (final m in widget.group.members)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          CircleAvatar(radius: 14,
                                              backgroundColor: _avatarColorFor(m.name),
                                              child: Text(m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                                                  style: const TextStyle(color: Colors.white, fontSize: 12))),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              m.id == _currentUserId ? '${m.name} (You)' : m.name,
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Text(
                                            _equalEditMembers.any((em) => em.id == m.id)
                                                ? _formatNumber(_amount > 0 ? _equalEditShare : 0)
                                                : '0',
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ] else ...[
                                _DetailRow(
                                  label: 'Split Type',
                                  value: expense.splitType == 'equally' ? 'Equal' : 'Custom',
                                ),
                                const SizedBox(height: 16),
                                _DetailRow(
                                  label: "${expense.paidBy?.name ?? ''}'s Share",
                                  value: _formatNumber(_payerShareAmount(expense)),
                                ),
                              ],
                              const SizedBox(height: 20),

                              if (!_isEditing)
                                Text("${expense.paidBy?.name ?? ''}'s Get Back",
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                              const SizedBox(height: 10),

                              if (_isEditing && _editSplitType == 'custom') ...[
                                Builder(builder: (context) {
                                  final sum = _customSplitSum;
                                  final total = _amount;
                                  final remaining = total - sum;
                                  final isComplete = total > 0 && remaining == 0;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isComplete
                                              ? const Color(0xFFDCF7DC)
                                              : const Color(0xFFFBEFD1),
                                          border: Border(
                                            left: BorderSide(
                                                color: isComplete
                                                    ? Colors.green
                                                    : Colors.orange,
                                                width: 4),
                                          ),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Total Split',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12.5)),
                                            Text(
                                                '${_formatNumber(sum)}/${_formatNumber(total)}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12.5)),
                                          ],
                                        ),
                                      ),
                                      if (!isComplete)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 4, left: 2),
                                          child: Text(
                                            'Remaining : ${_formatNumber(remaining < 0 ? 0 : remaining)}',
                                            style: TextStyle(
                                                color: Colors.orange[800],
                                                fontSize: 11),
                                          ),
                                        ),
                                      const SizedBox(height: 10),
                                    ],
                                  );
                                }),
                                for (final m in widget.group.members)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        CircleAvatar(radius: 14,
                                            backgroundColor: _avatarColorFor(m.name),
                                            child: Text(m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                                                style: const TextStyle(color: Colors.white, fontSize: 12))),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            m.id == _currentUserId ? '${m.name} (You)' : m.name,
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 90,
                                          child: TextField(
                                            controller: _splitControllers[m.id],
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.right,
                                            decoration: _editDecoration(dense: true),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ] else if (!_isEditing)
                                for (final p in expense.participants) ...[
                                  _SplitBreakdownRow(person: p),
                                  const SizedBox(height: 10),
                                ],
                              const SizedBox(height: 10),

                              Align(
                                alignment: Alignment.centerRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: isBusy
                                          ? null
                                          : () => _isEditing
                                              ? setState(() => _isEditing = false)
                                              : _confirmDelete(expense!),
                                      style: TextButton.styleFrom(
                                        backgroundColor: const Color(0xFFEDE7F6),
                                        foregroundColor: const Color(0xFF4A4A4A),
                                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                        shape: const StadiumBorder(),
                                        elevation: 0,
                                      ),
                                      child: Text(_isEditing ? 'Cancel' : 'Delete',
                                          style: const TextStyle(fontWeight: FontWeight.w600)),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: isBusy
                                          ? null
                                          : () => _isEditing
                                              ? _saveEdit(expense!)
                                              : _startEditing(expense!),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kDetailPurple,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                                        shape: const StadiumBorder(),
                                        elevation: 0,
                                      ),
                                      child: isBusy
                                          ? const SizedBox(height: 18, width: 18,
                                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                          : Text(_isEditing ? 'Save' : 'Edit',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      );

  InputDecoration _editDecoration({bool dense = false}) => InputDecoration(
        isDense: dense,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: dense ? 8 : 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dense ? 8 : 10),
          borderSide: BorderSide(color: kDetailPurple.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dense ? 8 : 10),
          borderSide: const BorderSide(color: kDetailPurple),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(dense ? 8 : 10)),
      );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  const _DetailRow({required this.label, this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        valueWidget ??
            Text(value ?? '',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

class _PersonChip extends StatelessWidget {
  final ExpensePerson person;
  const _PersonChip({required this.person});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: _avatarColorFor(person.name),
          child: Text(person.initial,
              style: const TextStyle(color: Colors.white, fontSize: 11)),
        ),
        const SizedBox(width: 8),
        Text(person.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

class _SplitBreakdownRow extends StatelessWidget {
  final ExpensePerson person;
  const _SplitBreakdownRow({required this.person});

  String _formatNumber(int n) {
    final s = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: kDetailPurple.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: _avatarColorFor(person.name),
            child: Text(person.initial,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(person.name,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          if (person.share != null)
            Text(_formatNumber(person.share!),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          if (person.isSettled) ...[
            const SizedBox(width: 8),
            const Icon(Icons.check_circle, color: Colors.green, size: 18),
          ],
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