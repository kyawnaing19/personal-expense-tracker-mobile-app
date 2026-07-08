// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../../models/category_model.dart';
// import '../bloc/category_bloc.dart' show CategoryBloc;
// import '../bloc/category_event.dart';
// import '../bloc/category_state.dart' show CategoryStateBase, CategoryLoaded, CategoryLoading;
// import '../screens/budget_utils.dart';
// import 'budget_category_picker.dart';

// class BudgetForm extends StatefulWidget {
//   final bool isEdit;
//   final CategoryItem? initialCategory;
//   final double? initialAmount;
//   final int? initialAlertPercentage;
//   final int initialMonth;
//   final int initialYear;
//   final String submitLabel;
//   final void Function({
//     required CategoryItem category,
//     required double amount,
//     required int alertPercentage,
//     required int month,
//     required int year,
//   }) onSubmit;
//   final VoidCallback onCancel;

//   const BudgetForm({
//     super.key,
//     required this.isEdit,
//     this.initialCategory,
//     this.initialAmount,
//     this.initialAlertPercentage,
//     required this.initialMonth,
//     required this.initialYear,
//     required this.submitLabel,
//     required this.onSubmit,
//     required this.onCancel,
//   });

//   @override
//   State<BudgetForm> createState() => _BudgetFormState();
// }

// class _BudgetFormState extends State<BudgetForm> {
//   bool _showCategoryPicker = false;
//   CategoryItem? _selectedCategory;
//   late int _selectedMonth;
//   late int _selectedYear;

//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _alertController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _selectedCategory = widget.initialCategory;
//     _selectedMonth = widget.initialMonth;
//     _selectedYear = widget.initialYear;
//     if (widget.initialAmount != null) {
//       _amountController.text = widget.initialAmount!.toInt().toString();
//     }
//     if (widget.initialAlertPercentage != null) {
//       _alertController.text = widget.initialAlertPercentage.toString();
//     }
//     context.read<CategoryBloc>().add(LoadCategories());
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _alertController.dispose();
//     super.dispose();
//   }

//   void _submit() {
//     final category = _selectedCategory;
//     final amount = double.tryParse(_amountController.text.trim());
//     final alert = int.tryParse(_alertController.text.trim());

//     if (category == null) {
//       _showError("Please choose a category.");
//       return;
//     }
//     if (amount == null || amount <= 0) {
//       _showError("Please enter a valid amount.");
//       return;
//     }
//     if (alert == null || alert <= 0 || alert > 100) {
//       _showError("Alert percentage must be between 1 and 100.");
//       return;
//     }

//     widget.onSubmit(
//       category: category,
//       amount: amount,
//       alertPercentage: alert,
//       month: _selectedMonth,
//       year: _selectedYear,
//     );
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.red),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     final years = selectableYears(now.year);
//     final months = selectableMonths(
//       selectedYear: _selectedYear,
//       currentMonth: now.month,
//       currentYear: now.year,
//     );

//     // NOTE: the category picker is rendered as its own section *below* this
//     // card (see the Column this method returns), not as a child inside the
//     // white "Set Budget" Container. That's what the design in the mockup
//     // shows: the picker sits on the screen background, underneath the
//     // Cancel/Set buttons, not squeezed between the fields and the buttons.
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text(
//                 widget.isEdit ? "Edit Budget" : "Set Budget",
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 25),

//               _formRow(
//                 "Choose Category",
//                 child: GestureDetector(
//                   onTap: () => setState(() => _showCategoryPicker = !_showCategoryPicker),
//                   child: _inputBox(
//                     child: Row(
//                       children: [
//                         if (_selectedCategory != null) ...[
//                           CircleAvatar(
//                             radius: 10,
//                             backgroundColor: _selectedCategory!.color,
//                             child: Icon(_selectedCategory!.icon, size: 12, color: Colors.white),
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(child: Text(_selectedCategory!.name, overflow: TextOverflow.ellipsis)),
//                         ] else
//                           const Expanded(child: Text("", style: TextStyle(color: Colors.grey))),
//                         const Icon(Icons.grid_view_rounded, size: 18, color: Color(0xFF8A4BEB)),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               _formRow("Amount", child: _inputBox(child: TextField(
//                 controller: _amountController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(border: InputBorder.none, isDense: true),
//               ))),

//               _formRow(
//                 "Month",
//                 child: Row(
//                   children: [
//                     // Month gets a bit more room than Year since it needs
//                     // to fit names like "Sep" / "Nov" plus the dropdown
//                     // arrow without clipping.
//                     Expanded(
//                       flex: 3,
//                       child: _inputBox(
//                         child: widget.isEdit
//                             ? Text(kMonthNamesShort[_selectedMonth - 1], style: const TextStyle(color: Colors.grey))
//                             : DropdownButtonHideUnderline(
//                                 child: DropdownButton<int>(
//                                   isExpanded: true,
//                                   isDense: true,
//                                   icon: const Icon(Icons.arrow_drop_down, size: 20, color: Color(0xFF8A4BEB)),
//                                   value: months.contains(_selectedMonth) ? _selectedMonth : months.first,
//                                   items: months
//                                       .map((m) => DropdownMenuItem(value: m, child: Text(kMonthNamesShort[m - 1])))
//                                       .toList(),
//                                   onChanged: (v) => setState(() => _selectedMonth = v ?? _selectedMonth),
//                                 ),
//                               ),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       flex: 2,
//                       child: _inputBox(
//                         padding: const EdgeInsets.symmetric(horizontal: 6),
//                         child: widget.isEdit
//                             ? Text(_selectedYear.toString(), style: const TextStyle(color: Colors.grey))
//                             : DropdownButtonHideUnderline(
//                                 child: DropdownButton<int>(
//                                   isExpanded: true,
//                                   isDense: true,
//                                   icon: const Icon(Icons.arrow_drop_down, size: 20, color: Color(0xFF8A4BEB)),
//                                   value: _selectedYear,
//                                   items: years
//                                       .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
//                                       .toList(),
//                                   onChanged: (v) {
//                                     setState(() {
//                                       _selectedYear = v ?? _selectedYear;
//                                       final validMonths = selectableMonths(
//                                         selectedYear: _selectedYear,
//                                         currentMonth: now.month,
//                                         currentYear: now.year,
//                                       );
//                                       if (!validMonths.contains(_selectedMonth)) {
//                                         _selectedMonth = validMonths.first;
//                                       }
//                                     });
//                                   },
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               _formRow("Alert Percentage", child: _inputBox(child: TextField(
//                 controller: _alertController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(border: InputBorder.none, isDense: true, suffixText: "%"),
//               ))),

//               const SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   _actionButton("Cancel", const Color(0xFF9E65FF), widget.onCancel),
//                   const SizedBox(width: 15),
//                   _actionButton(widget.submitLabel, const Color(0xFF8A4BEB), _submit),
//                 ],
//               ),
//             ],
//           ),
//         ),

//         // Category picker section — appears BELOW the card above, directly
//         // on the screen background, matching the design.
//         if (_showCategoryPicker)
//           Padding(
//             padding: const EdgeInsets.only(top: 24),
//             child: BlocBuilder<CategoryBloc, CategoryStateBase>(
//               builder: (context, state) {
//                 if (state is CategoryLoading) {
//                   return const Padding(
//                     padding: EdgeInsets.symmetric(vertical: 20),
//                     child: Center(child: CircularProgressIndicator(color: Color(0xFF8A4BEB))),
//                   );
//                 }
//                 // Budgets can only ever be set against expense categories
//                 // (there's no such thing as a "budget" for income), so we
//                 // filter out anything else here before it ever reaches the
//                 // picker grid.
//                 final categories = state is CategoryLoaded
//                     ? state.categories.where((c) => c.type == 'expense').toList()
//                     : <CategoryItem>[];
//                 return BudgetCategoryPicker(
//                   categories: categories,
//                   selected: _selectedCategory,
//                   onSelected: (cat) => setState(() {
//                     _selectedCategory = cat;
//                     _showCategoryPicker = false;
//                   }),
//                 );
//               },
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _formRow(String label, {required Widget child}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
//           Expanded(flex: 3, child: child),
//         ],
//       ),
//     );
//   }

//   Widget _inputBox({required Widget child, EdgeInsetsGeometry? padding}) {
//     return Container(
//       constraints: const BoxConstraints(minHeight: 40),
//       alignment: Alignment.centerLeft,
//       decoration: BoxDecoration(color: const Color(0xFFE2D9F3), borderRadius: BorderRadius.circular(8)),
//       padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       child: child,
//     );
//   }

//   Widget _actionButton(String label, Color color, VoidCallback onTap) {
//     return SizedBox(
//       width: 90,
//       height: 40,
//       child: ElevatedButton(
//         onPressed: onTap,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           padding: EdgeInsets.zero,
//         ),
//         child: Text(label, style: const TextStyle(color: Colors.white)),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/category_model.dart';
import '../bloc/category_bloc.dart' show CategoryBloc;
import '../bloc/category_event.dart';
import '../bloc/category_state.dart' show CategoryStateBase, CategoryLoaded, CategoryLoading;
import '../screens/budget_utils.dart';
import 'budget_category_picker.dart';

class BudgetForm extends StatefulWidget {
  final bool isEdit;
  final CategoryItem? initialCategory;
  final double? initialAmount;
  final int? initialAlertPercentage;
  final int initialMonth;
  final int initialYear;
  final String submitLabel;
  final void Function({
    required CategoryItem category,
    required double amount,
    required int alertPercentage,
    required int month,
    required int year,
  }) onSubmit;
  final VoidCallback onCancel;

  const BudgetForm({
    super.key,
    required this.isEdit,
    this.initialCategory,
    this.initialAmount,
    this.initialAlertPercentage,
    required this.initialMonth,
    required this.initialYear,
    required this.submitLabel,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends State<BudgetForm> {
  bool _showCategoryPicker = false;
  CategoryItem? _selectedCategory;
  late int _selectedMonth;
  late int _selectedYear;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _alertController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _selectedMonth = widget.initialMonth;
    _selectedYear = widget.initialYear;
    if (widget.initialAmount != null) {
      _amountController.text = widget.initialAmount!.toInt().toString();
    }
    if (widget.initialAlertPercentage != null) {
      _alertController.text = widget.initialAlertPercentage.toString();
    }
    context.read<CategoryBloc>().add(LoadCategories());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _alertController.dispose();
    super.dispose();
  }

  void _submit() {
    final category = _selectedCategory;
    final amount = double.tryParse(_amountController.text.trim());
    final alert = int.tryParse(_alertController.text.trim());

    if (category == null) {
      _showError("Please choose a category.");
      return;
    }
    if (amount == null || amount <= 0) {
      _showError("Please enter a valid amount.");
      return;
    }
    if (alert == null || alert <= 0 || alert > 100) {
      _showError("Alert percentage must be between 1 and 100.");
      return;
    }

    widget.onSubmit(
      category: category,
      amount: amount,
      alertPercentage: alert,
      month: _selectedMonth,
      year: _selectedYear,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final years = selectableYears(now.year);
    final months = selectableMonths(
      selectedYear: _selectedYear,
      currentMonth: now.month,
      currentYear: now.year,
    );

    // NOTE: the category picker is rendered as its own section *below* this
    // card (see the Column this method returns), not as a child inside the
    // white "Set Budget" Container. That's what the design in the mockup
    // shows: the picker sits on the screen background, underneath the
    // Cancel/Set buttons, not squeezed between the fields and the buttons.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.isEdit ? "Edit Budget" : "Set Budget",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),

              _formRow(
                "Choose Category",
                child: GestureDetector(
                  onTap: () => setState(() => _showCategoryPicker = !_showCategoryPicker),
                  child: _inputBox(
                    child: Row(
                      children: [
                        if (_selectedCategory != null) ...[
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: _selectedCategory!.color,
                            child: Icon(_selectedCategory!.icon, size: 12, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_selectedCategory!.name, overflow: TextOverflow.ellipsis)),
                        ] else
                          const Expanded(child: Text("", style: TextStyle(color: Colors.grey))),
                        const Icon(Icons.grid_view_rounded, size: 18, color: Color(0xFF8A4BEB)),
                      ],
                    ),
                  ),
                ),
              ),

              _formRow("Amount", child: _inputBox(child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
              ))),

              _formRow(
                "Month",
                child: Row(
                  children: [
                    Expanded(
                      child: _inputBox(
                        child: widget.isEdit
                            ? Text(kMonthNamesShort[_selectedMonth - 1], style: const TextStyle(color: Colors.grey))
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  isDense: true,
                                  icon: const Icon(Icons.arrow_drop_down, size: 20, color: Color(0xFF8A4BEB)),
                                  value: months.contains(_selectedMonth) ? _selectedMonth : months.first,
                                  items: months
                                      .map((m) => DropdownMenuItem(value: m, child: Text(kMonthNamesShort[m - 1])))
                                      .toList(),
                                  onChanged: (v) => setState(() => _selectedMonth = v ?? _selectedMonth),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _inputBox(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: widget.isEdit
                            ? Text(_selectedYear.toString(), style: const TextStyle(color: Colors.grey))
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  isDense: true,
                                  icon: const Icon(Icons.arrow_drop_down, size: 20, color: Color(0xFF8A4BEB)),
                                  value: _selectedYear,
                                  items: years
                                      .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
                                      .toList(),
                                  onChanged: (v) {
                                    setState(() {
                                      _selectedYear = v ?? _selectedYear;
                                      final validMonths = selectableMonths(
                                        selectedYear: _selectedYear,
                                        currentMonth: now.month,
                                        currentYear: now.year,
                                      );
                                      if (!validMonths.contains(_selectedMonth)) {
                                        _selectedMonth = validMonths.first;
                                      }
                                    });
                                  },
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              _formRow("Alert Percentage", child: _inputBox(child: TextField(
                controller: _alertController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: InputBorder.none, isDense: true, suffixText: "%"),
              ))),

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _actionButton("Cancel", const Color(0xFF9E65FF), widget.onCancel),
                  const SizedBox(width: 15),
                  _actionButton(widget.submitLabel, const Color(0xFF8A4BEB), _submit),
                ],
              ),
            ],
          ),
        ),

        // Category picker section — appears BELOW the card above, on its
        // own white card (same style as the Category Type sheet in
        // record_history_screen.dart), not floating directly on the
        // purple screen background.
        if (_showCategoryPicker)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: BlocBuilder<CategoryBloc, CategoryStateBase>(
                builder: (context, state) {
                  if (state is CategoryLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF8A4BEB))),
                    );
                  }
                  // Budgets can only ever be set against expense categories
                  // (there's no such thing as a "budget" for income), so we
                  // filter out anything else here before it ever reaches the
                  // picker grid.
                  final categories = state is CategoryLoaded
                      ? state.categories.where((c) => c.type == 'expense').toList()
                      : <CategoryItem>[];
                  return BudgetCategoryPicker(
                    categories: categories,
                    selected: _selectedCategory,
                    onSelected: (cat) => setState(() {
                      _selectedCategory = cat;
                      _showCategoryPicker = false;
                    }),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _formRow(String label, {required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          Expanded(flex: 3, child: child),
        ],
      ),
    );
  }

  Widget _inputBox({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(color: const Color(0xFFE2D9F3), borderRadius: BorderRadius.circular(8)),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: child,
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: 90,
      height: 40,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.zero,
        ),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}