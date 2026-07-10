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
  
  // Controller များ
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  // Local State Variables
  late double _currentAmount;
  late String _currentNote;

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
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: const Color(0xFFE8DEF8), // AppBar Background
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Arrow Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black),
                ),
              ),
              Text(
                _isEditing ? "Edit Transaction Details" : "Transaction Details",
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(width: 36, height: 36),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 40), 
                CircleAvatar(
                  radius: 26,
                  backgroundColor: widget.categoryColor,
                  child: Icon(widget.categoryIcon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 40), 
                Expanded(
                  child: Text(
                    widget.categoryName,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildDetailRow("Type", Text(isExpense ? "Expense" : "Income", style: const TextStyle(fontSize: 16, color: Colors.black38))),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildDetailRow(
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
                        : Text(formatter.format(_currentAmount), style: const TextStyle(fontSize: 16, color: Colors.black)),
                  ),
                ),
                if (_isEditing)
                  const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(Icons.edit_outlined, size: 18, color: Colors.black38),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            _buildDetailRow(
              "Date",
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('MMM d, yyyy').format(widget.transaction.createdAt.toLocal()), style: const TextStyle(fontSize: 16, color: Colors.black38)),
                  Text("(${DateFormat('HH:mm:ss').format(widget.transaction.createdAt.toLocal())})", style: const TextStyle(fontSize: 13, color: Colors.black38)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildDetailRow(
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
                        : Text(_currentNote.isEmpty ? "No note" : _currentNote, style: const TextStyle(fontSize: 16, color: Colors.black)),
                  ),
                ),
                if (_isEditing)
                  const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(Icons.edit_outlined, size: 18, color: Colors.black38),
                  ),
              ],
            ),
            
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _isEditing
                  ? [
                      _buildBottomButton(
                        label: "Cancel",
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _amountController.text = _currentAmount.toInt().toString();
                            _noteController.text = _currentNote == "No note" ? "" : _currentNote;
                          });
                        },
                      ),
                       _buildBottomButton(
  label: "Done",
  onPressed: () {
    final updatedAmount = double.tryParse(_amountController.text) ?? _currentAmount;
    final updatedNote = _noteController.text.trim().isEmpty ? "No note" : _noteController.text.trim();

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
                      _buildBottomButton(
                        label: "Edit",
                        onPressed: () => setState(() => _isEditing = true),
                      ),
                     _buildBottomButton(
  label: "Delete",
  onPressed: () {
    BlocProvider.of<TransactionBloc>(context).add(
      DeleteTransactionRequested(widget.transaction.id)
    );
    Navigator.pop(context); 
  },
),
                    ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  Widget _buildDetailRow(String title, Widget valueWidget) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 40), 
        SizedBox(
          width: 92, 
          child: Text(
            title,
            style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: valueWidget,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton({required String label, VoidCallback? onPressed}) {
    return SizedBox(
      width: 130,
      height: 42,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B5CF6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}