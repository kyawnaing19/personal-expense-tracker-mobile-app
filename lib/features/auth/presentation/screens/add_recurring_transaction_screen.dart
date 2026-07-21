import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/models/category_model.dart';
import 'package:expense_tracker/models/recurring_transaction_model.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/category_state.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/recurring_transaction_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/recurring_transaction_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/recurring_transaction_state.dart';

class AddRecurringTransactionScreen extends StatefulWidget {
  final RecurringTransactionItem? existing;

  const AddRecurringTransactionScreen({Key? key, this.existing}) : super(key: key);

  @override
  State<AddRecurringTransactionScreen> createState() => _AddRecurringTransactionScreenState();
}

class _AddRecurringTransactionScreenState extends State<AddRecurringTransactionScreen> {
  final Color primaryPurple = const Color(0xFF7F3DFF);

  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  CategoryItem? _selectedCategory;
  String? _selectedFrequency; 
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));

  bool get _isEditing => widget.existing != null;

  final List<Map<String, String>> _frequencies = const [
    {'value': 'daily', 'label': 'Daily'},
    {'value': 'weekly', 'label': 'Weekly'},
    {'value': 'monthly', 'label': 'Monthly'},
  ];

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());

    final existing = widget.existing;
    if (existing != null) {
      _amountController.text = existing.amount.toInt().toString();
      _noteController.text = existing.note;
      _selectedFrequency = existing.frequency;
      _startDate = existing.startDate;

      final categoryState = context.read<CategoryBloc>().state;
      if (categoryState is CategoryLoaded) {
        _selectedCategory = categoryState.categories.firstWhere(
          (c) => c.id == existing.categoryId,
          orElse: () => categoryState.categories.first,
        );
        
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _pickCategory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
      builder: (context) {
        return BlocBuilder<CategoryBloc, CategoryStateBase>(
          builder: (context, state) {
            List<CategoryItem> categories = state is CategoryLoaded ? state.categories : [];
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
                    child: categories.isEmpty
                        ? const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('No categories yet. Please add one first.', style: TextStyle(color: Colors.grey)))
                        : GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: categories.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 20, crossAxisSpacing: 10, childAspectRatio: 0.8),
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              final isSelected = _selectedCategory?.id == category.id;
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                  Navigator.pop(context);
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
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) => setState(() {}));
  }

  Future<void> _pickStartDate() async {
  final today = DateTime.now();
  final firstSelectable = DateTime(today.year, today.month, today.day).add(const Duration(days: 1));
  final picked = await showDatePicker(
      context: context,
      initialDate: _startDate.isBefore(firstSelectable) ? firstSelectable : _startDate,
      firstDate: firstSelectable,
      lastDate: DateTime(today.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: primaryPurple, onPrimary: Colors.white, onSurface: Colors.black)),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  void _pickFrequency() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _frequencies.map((f) {
              return ListTile(
                title: Text(f['label']!),
                trailing: _selectedFrequency == f['value'] ? Icon(Icons.check, color: primaryPurple) : null,
                onTap: () {
                  setState(() => _selectedFrequency = f['value']);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
  String _upcomingDatesPreview() {
    final fmt = DateFormat('MMM d, yyyy');
    List<DateTime> dates;
    switch (_selectedFrequency) {
      case 'daily':
        dates = [
          _startDate,
          _startDate.add(const Duration(days: 1)),
          _startDate.add(const Duration(days: 2)),
        ];
        break;
      case 'weekly':
        dates = [
          _startDate,
          _startDate.add(const Duration(days: 7)),
          _startDate.add(const Duration(days: 14)),
        ];
        break;
      case 'monthly':
        dates = [
          _startDate,
          DateTime(_startDate.year, _startDate.month + 1, _startDate.day),
          DateTime(_startDate.year, _startDate.month + 2, _startDate.day),
        ];
        break;
      default:
        dates = [_startDate];
    }
    final joined = dates.map(fmt.format).join('  •  ');
    return 'Transaction date : $joined ...';
  }

  void _submit() {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }
    if (_selectedFrequency == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a transaction frequency')));
      return;
    }
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount')));
      return;
    }

    if (_isEditing) {
      context.read<RecurringTransactionBloc>().add(
            UpdateRecurringTransactionRequested(
              id: widget.existing!.id,
              categoryId: _selectedCategory!.id,
              amount: amount,
              frequency: _selectedFrequency!,
              startDate: _startDate,
              note: _noteController.text.trim(),
            ),
          );
    } else {
      context.read<RecurringTransactionBloc>().add(
            AddRecurringTransactionRequested(
              categoryId: _selectedCategory!.id,
              amount: amount,
              frequency: _selectedFrequency!,
              startDate: _startDate,
              note: _noteController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 340 ? 12.0 : (screenWidth >= 600 ? 32.0 : 16.0);

    return Scaffold(
      backgroundColor: const Color(0xFFEDE7F6),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: BlocListener<RecurringTransactionBloc, RecurringTransactionStateBase>(
          listener: (context, state) {
            if (state is RecurringTransactionActionSuccess) {
              Navigator.pop(context);
            } else if (state is RecurringTransactionError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 16.0, horizontalPadding, 0),
                    child: _buildTopHeader(),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, MediaQuery.of(context).viewInsets.bottom + 16.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          _buildLabel('Transaction Name'),
                      _buildTextField(controller: _nameController, hint: 'Please enter the transaction name'),
                      const SizedBox(height: 14),

                      _buildLabel('Category'),
                      _buildDropdownLikeBox(
                        onTap: _pickCategory,
                        child: _selectedCategory == null
                            ? const Text('Select category', style: TextStyle(color: Colors.black38))
                            : Row(children: [
                                CircleAvatar(radius: 12, backgroundColor: _selectedCategory!.color, child: Icon(_selectedCategory!.icon, size: 14, color: Colors.white)),
                                const SizedBox(width: 8),
                                Text(_selectedCategory!.name, style: const TextStyle(color: Colors.black)),
                              ]),
                      ),
                      const SizedBox(height: 14),

                      _buildLabel('Type'),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E7EB))),
                        child: Text(
                          _selectedCategory == null ? ' ' : (_selectedCategory!.type[0].toUpperCase() + _selectedCategory!.type.substring(1)),
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                      const SizedBox(height: 14),

                      _buildLabel('Transaction Frequency'),
                      _buildDropdownLikeBox(
                        onTap: _pickFrequency,
                        child: Text(
                          _selectedFrequency == null ? 'Select frequency' : _selectedFrequency![0].toUpperCase() + _selectedFrequency!.substring(1),
                          style: TextStyle(color: _selectedFrequency == null ? Colors.black38 : Colors.black),
                        ),
                      ),
                      const SizedBox(height: 14),

                      _buildLabel('Transaction Start Date'),
                      _buildDropdownLikeBox(onTap: _pickStartDate, child: Text(DateFormat('MMMM d, yyyy').format(_startDate))),
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _upcomingDatesPreview(),
                          style: const TextStyle(color: Colors.black38, fontSize: 11),
                        ),
                      ),
                      const SizedBox(height: 14),

                      _buildLabel('Amount'),
                      _buildTextField(controller: _amountController, hint: '0', keyboardType: TextInputType.number),
                      const SizedBox(height: 14),

                      _buildLabel('Note'),
                      _buildTextField(controller: _noteController, hint: 'Optional note'),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: BorderSide(color: primaryPurple, width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Text('Cancel', style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: BlocBuilder<RecurringTransactionBloc, RecurringTransactionStateBase>(
                              builder: (context, state) {
                                final loading = state is RecurringTransactionLoading;
                                return SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: loading ? null : _submit,
                                    style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                    child: loading
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                        : const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,), child: const Icon(Icons.arrow_back_ios_outlined, size: 20, color: Colors.black)),
        ),
        const SizedBox(width: 45),
        Text(_isEditing ? 'Edit Recurring Transaction' : 'Add Recurring Transactions', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
      ],
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
      );

  Widget _buildTextField({required TextEditingController controller, required String hint, TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.black38), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      ),
    );
  }

  Widget _buildDropdownLikeBox({required VoidCallback onTap, required Widget child}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E7EB))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Expanded(child: child), const Icon(Icons.keyboard_arrow_down, color: Colors.black38)],
        ),
      ),
    );
  }
}