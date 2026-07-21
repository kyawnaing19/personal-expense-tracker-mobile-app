import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/transaction_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/transaction_event.dart';

class TransactionDetailScreen extends StatefulWidget {
  final TransactionItem transaction;
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;

  const TransactionDetailScreen({
    Key? key,
    required this.transaction,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
  }) : super(key: key);

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  bool _isEditing = false;

  late TextEditingController _amountController;
  late TextEditingController _noteController;

  late double _currentAmount;
  late String _currentNote;

  static const Color _bgColor = Color(0xFFE6DEF7); 
  static const Color _primaryPurple = Color(0xFF7C3AED); 

  static const double _labelColWidth = 80;
  static const double _pencilColWidth = 22;

  @override
  void initState() {
    super.initState();
    _currentAmount = widget.transaction.amount;
    _currentNote = widget.transaction.note;

    _amountController = TextEditingController(text: _currentAmount.toInt().toString());
    _noteController = TextEditingController(text: _currentNote == "No note" ? "" : _currentNote);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0');
    final isExpense = widget.transaction.type == 'expense';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_outlined, size: 20, color: Colors.black),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Record Details",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 40, height: 40),
                ],
              ),

              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Table(
                          columnWidths: const {
                            0: FixedColumnWidth(_labelColWidth),
                            1: FixedColumnWidth(12),
                            2: FlexColumnWidth(),
                            3: FixedColumnWidth(_pencilColWidth),
                          },
                          defaultVerticalAlignment: TableCellVerticalAlignment.top,
                          children: [
                            TableRow(
                              children: [
                                TableCell(
                                  verticalAlignment: TableCellVerticalAlignment.middle,
                                  child: CircleAvatar(
                                    radius: 22,
                                    backgroundColor: widget.categoryColor,
                                    child: Icon(widget.categoryIcon, color: Colors.white, size: 22),
                                  ),
                                ),
                                const SizedBox(),
                                TableCell(
                                  verticalAlignment: TableCellVerticalAlignment.middle,
                                  child: Text(
                                    widget.categoryName,
                                    style: const TextStyle(fontSize: 16, color: Colors.black),
                                  ),
                                ),
                                TableCell(
                                  verticalAlignment: TableCellVerticalAlignment.middle,
                                  child: _isEditing
                                      ? const Icon(Icons.edit_outlined, size: 18, color: Colors.black38)
                                      : const SizedBox(),
                                ),
                              ],
                            ),
                            _spacerRow(28),
                            _buildTableRow(
                              "Type",
                              Text(isExpense ? "Expense" : "Income",
                                  style: const TextStyle(fontSize: 16, color: Colors.black38)),
                            ),
                            _spacerRow(22),
                            _buildTableRow(
                              "Amount",
                              _isEditing
                                  ? TextField(
                                      controller: _amountController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 16, color: Colors.black),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    )
                                  : Text(formatter.format(_currentAmount),
                                      style: const TextStyle(fontSize: 16, color: Colors.black)),
                              showEditIcon: _isEditing,
                            ),
                            _spacerRow(22),
                            _buildTableRow(
                              "Date",
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(DateFormat('MMM d, yyyy').format(widget.transaction.createdAt.toLocal()),
                                      style: const TextStyle(fontSize: 16, color: Colors.black38)),
                                  Text("(${DateFormat('HH:mm:ss').format(widget.transaction.createdAt.toLocal())})",
                                      style: const TextStyle(fontSize: 13, color: Colors.black38)),
                                ],
                              ),
                            ),
                            _spacerRow(22),
                            _buildTableRow(
                              "Note",
                              _isEditing
                                  ? TextField(
                                      controller: _noteController,
                                      style: const TextStyle(fontSize: 16, color: Colors.black),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    )
                                  : Text(_currentNote.isEmpty ? "No note" : _currentNote,
                                      style: const TextStyle(fontSize: 16, color: Colors.black)),
                              showEditIcon: _isEditing,
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: _isEditing
                              ? [
                                  _buildSecondaryButton(
                                    label: "Cancel",
                                    onPressed: () {
                                      setState(() {
                                        _isEditing = false;
                                        _amountController.text = _currentAmount.toInt().toString();
                                        _noteController.text = _currentNote == "No note" ? "" : _currentNote;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  _buildPrimaryButton(
                                    label: "Done",
                                    onPressed: () {
                                      final updatedAmount =
                                          double.tryParse(_amountController.text) ?? _currentAmount;
                                      final updatedNote = _noteController.text.trim().isEmpty
                                          ? "No note"
                                          : _noteController.text.trim();

                                      BlocProvider.of<TransactionBloc>(context).add(
                                        UpdateTransactionRequested(
                                          id: widget.transaction.id,
                                          amount: updatedAmount,
                                          note: updatedNote,
                                        ),
                                      );
                                      Navigator.pop(context);
                                    },
                                  ),
                                ]
                              : [
                                  _buildSecondaryButton(
                                    label: "Delete",
                                    onPressed: () {
                                      BlocProvider.of<TransactionBloc>(context)
                                          .add(DeleteTransactionRequested(widget.transaction.id));
                                      Navigator.pop(context);
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  _buildPrimaryButton(
                                    label: "Edit",
                                    onPressed: () => setState(() => _isEditing = true),
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
    );
  }

  TableRow _buildTableRow(String title, Widget valueWidget, {bool showEditIcon = false}) {
    return TableRow(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal),
        ),
        const SizedBox(),
        valueWidget,
        showEditIcon
            ? const Icon(Icons.edit_outlined, size: 18, color: Colors.black38)
            : const SizedBox(),
      ],
    );
  }

  TableRow _spacerRow(double height) {
    return TableRow(
      children: [SizedBox(height: height), SizedBox(height: height), SizedBox(height: height), SizedBox(height: height)],
    );
  }

  Widget _buildPrimaryButton({required String label, VoidCallback? onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryPurple,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildSecondaryButton({required String label, VoidCallback? onPressed}) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: _bgColor.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: BorderSide(color: _primaryPurple.withOpacity(0.5), width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(color: _primaryPurple, fontSize: 15, fontWeight: FontWeight.w500),
      ),
    );
  }
}