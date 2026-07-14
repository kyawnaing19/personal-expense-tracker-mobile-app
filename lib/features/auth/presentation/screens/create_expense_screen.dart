import 'package:expense_tracker/core/services/current_user_service..dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/group_model.dart';
import '../../data/expense_repository.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';

const Color kExpenseBg = Color(0xFFE8DEF8);
const Color kExpensePurple = Color(0xFF6200EE);

class CreateExpenseScreen extends StatefulWidget {
  final GroupModel group;
  const CreateExpenseScreen({Key? key, required this.group}) : super(key: key);

  @override
  State<CreateExpenseScreen> createState() => _CreateExpenseScreenState();
}

class _CreateExpenseScreenState extends State<CreateExpenseScreen> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final Map<String, TextEditingController> _splitControllers = {};

  String? _splitType; // null | 'equally' | 'custom'
  bool _includePayer = true; // Include Me (default) / Exclude Me
  DateTime? _selectedDate;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _amountController.addListener(() => setState(() {}));
    for (final m in widget.group.members) {
      _splitControllers[m.id] = TextEditingController()
        ..addListener(() => setState(() {}));
    }
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await CurrentUserService.getCurrentUser();
    if (mounted) setState(() => _currentUserId = user['id']);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    for (final c in _splitControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  int get _amount => int.tryParse(_amountController.text.trim()) ?? 0;

  int get _customSplitSum {
    int sum = 0;
    for (final c in _splitControllers.values) {
      sum += int.tryParse(c.text.trim()) ?? 0;
    }
    return sum;
  }

  // Equal split preview - Include Me ရွေးထားရင် member အားလုံး (ကိုယ်တိုင်
  // အပါအဝင်) ရဲ့ ရေအတွက်နဲ့ ခွဲတွက်ပြီး, Exclude Me ရွေးထားရင် ကိုယ်တိုင်
  // ကိုထုတ်ပြီး ကျန်တဲ့ member အရေအတွက်နဲ့ပဲ ခွဲတွက်ပေးတယ် (backend ဘက်ကလည်း
  // include_payer flag ကို ဒီအတိုင်းပဲ သုံးပြီး တွက်ပေးတယ်)
  List<dynamic> get _equalSplitMembers {
    final members = widget.group.members;
    return _includePayer
        ? members
        : members.where((m) => m.id != _currentUserId).toList();
  }

  int get _equalShare {
    final totalMembers =
        _equalSplitMembers.isNotEmpty ? _equalSplitMembers.length : 1;
    return (_amount / totalMembers).round();
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    // past, current, future date အားလုံး ရွေးလို့ရအောင် wide range ပေးထားတယ်
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      // card ကို အဖြူရောင်၊ header/selected-date/OK ခလုတ်တွေကို
      // app ရဲ့ ခရမ်းရောင် (kExpensePurple) အတိုင်း theme ပြင်တာ
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kExpensePurple, // header bg + selected day
              onPrimary: Colors.white, // header text + selected day text
              onSurface: Colors.black87, // calendar body text
              surface: Colors.white, // dialog background
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: kExpensePurple),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _submit() {
    if (_amount <= 0) {
      _showError('Amount ထည့်ပေးပါ');
      return;
    }
    if (_splitType == null) {
      _showError('Split Type ရွေးပေးပါ');
      return;
    }
    if (_selectedDate == null) {
      _showError('Date ရွေးပေးပါ');
      return;
    }

    List<ExpenseSplitInput>? splits;
    if (_splitType == 'custom') {
      if (_customSplitSum != _amount) {
        _showError('Total Split ကို Amount အတိုင်း အပြည့်ခွဲပေးပါ');
        return;
      }
      splits = widget.group.members
          .map((m) => ExpenseSplitInput(
                userId: m.id,
                amountOwed:
                    int.tryParse(_splitControllers[m.id]?.text.trim() ?? '') ??
                        0,
              ))
          .where((s) => s.amountOwed > 0)
          .toList();
      if (splits.isEmpty) {
        _showError('Member တစ်ယောက်ချင်းစီအတွက် amount ခွဲပေးပါ');
        return;
      }
    }

    context.read<ExpenseBloc>().add(CreateExpenseRequested(
          groupId: widget.group.id,
          amount: _amount,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          expenseDate: _selectedDate!,
          splitType: _splitType!,
          includePayer: _splitType == 'equally' ? _includePayer : null,
          splits: splits,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExpenseBloc, ExpenseStateBase>(
      listener: (context, state) {
        if (state is ExpenseCreateSuccess) {
          Navigator.pop(context, true);
        } else if (state is ExpenseError) {
          _showError(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: kExpenseBg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _RoundIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Create Expense',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    // Cancel/Done ကို scroll area အပြင်ဘက် static footer
                    // အနေနဲ့ ခွဲထားလိုက်တယ် - fields တွေများပြီး scroll
                    // ဖြစ်လာရင်တောင် ဒီ button ၂ခုက အမြဲမြင်ရအောင်
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                          _label('Description'),
                          TextField(
                            controller: _descriptionController,
                            decoration: _inputDecoration(
                                hint: 'e.g Eating Pizza, Buying Cosmetics'),
                          ),
                          const SizedBox(height: 18),
                          _label('Amount'),
                          TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(),
                          ),
                          const SizedBox(height: 18),
                          _label('Group'),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: kExpensePurple.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Text(widget.group.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Text('${widget.group.memberCount} members',
                                    style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          _label('Split Type'),
                          Row(
                            children: [
                              Expanded(
                                  child: _splitTypeButton('Equal', 'equally')),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: _splitTypeButton('Custom', 'custom')),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_splitType == 'equally') _buildEqualSection(),
                          if (_splitType == 'custom') _buildCustomSection(),
                          const SizedBox(height: 18),
                          _label('Date'),
                          InkWell(
                            onTap: _pickDate,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: kExpensePurple.withOpacity(0.4)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_selectedDate != null
                                      ? _formatDate(_selectedDate!)
                                      : 'Select date'),
                                  const Icon(Icons.calendar_today_outlined,
                                      size: 18, color: kExpensePurple),
                                ],
                              ),
                            ),
                          ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Cancel/Done - scroll area ရဲ့ အပြင်ဘက်မှာ static
                        // footer အနေနဲ့ထားလို့ ဘယ်လောက်ပဲ scroll လုပ်လုပ်
                        // အမြဲမြင်ရမယ်
                        BlocBuilder<ExpenseBloc, ExpenseStateBase>(
                          builder: (context, state) {
                            final isSubmitting = state is ExpenseCreating;
                            return Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: isSubmitting
                                        ? null
                                        : () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: isSubmitting ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kExpensePurple,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    child: isSubmitting
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white),
                                          )
                                        : const Text('Done',
                                            style: TextStyle(
                                                color: Colors.white)),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      );

  InputDecoration _inputDecoration({String? hint}) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: kExpensePurple.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kExpensePurple),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      );

  Widget _splitTypeButton(String label, String value) {
    final selected = _splitType == value;
    return OutlinedButton(
      onPressed: () => setState(() => _splitType = value),
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? kExpensePurple : Colors.white,
        side:
            BorderSide(color: kExpensePurple.withOpacity(selected ? 1 : 0.4)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label,
          style:
              TextStyle(color: selected ? Colors.white : Colors.black87)),
    );
  }

  Widget _buildEqualSection() {
    final displayed = _equalSplitMembers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: _includePayer,
              activeColor: kExpensePurple,
              onChanged: (v) => setState(() => _includePayer = v!),
            ),
            const Text('Include Me', style: TextStyle(fontSize: 12.5)),
            const SizedBox(width: 6),
            Radio<bool>(
              value: false,
              groupValue: _includePayer,
              activeColor: kExpensePurple,
              onChanged: (v) => setState(() => _includePayer = v!),
            ),
            const Text('Exclude Me', style: TextStyle(fontSize: 12.5)),
          ],
        ),
        const SizedBox(height: 4),
        ...displayed.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _MemberRow(
                name: m.name,
                isYou: m.id == _currentUserId,
                trailing: Text(
                  _formatNumber(_amount > 0 ? _equalShare : 0),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildCustomSection() {
    final sum = _customSplitSum;
    final total = _amount;
    final remaining = total - sum;
    final isComplete = total > 0 && remaining == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            // ခွဲပြီးရင် အစိမ်း / မခွဲရသေးရင် အဝါ
            color: isComplete
                ? const Color(0xFFDCF7DC)
                : const Color(0xFFFBEFD1),
            border: Border(
              left: BorderSide(
                  color: isComplete ? Colors.green : Colors.orange, width: 4),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Split',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
              Text('${_formatNumber(sum)}/${_formatNumber(total)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 12.5)),
            ],
          ),
        ),
        if (!isComplete)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2),
            child: Text(
              'Remaining : ${_formatNumber(remaining < 0 ? 0 : remaining)}',
              style: TextStyle(color: Colors.orange[800], fontSize: 11),
            ),
          ),
        const SizedBox(height: 10),
        ...widget.group.members.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _MemberRow(
                name: m.name,
                isYou: m.id == _currentUserId,
                trailing: SizedBox(
                  width: 90,
                  child: TextField(
                    controller: _splitControllers[m.id],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: kExpensePurple.withOpacity(0.4)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kExpensePurple),
                      ),
                      border:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
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
}

class _MemberRow extends StatelessWidget {
  final String name;
  final bool isYou;
  final Widget trailing;
  const _MemberRow(
      {required this.name, required this.isYou, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: kExpensePurple,
          child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(isYou ? '$name (You)' : name,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ),
        trailing,
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