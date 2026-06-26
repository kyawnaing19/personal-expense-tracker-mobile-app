import 'package:expense_tracker/models/record_model.dart';
import 'package:flutter/material.dart';

class TransactionDetailScreen extends StatefulWidget {
  final RecordItem item;

  const TransactionDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  bool _isEditing = false;
  late String _displayAmount;
  late String _displayNote;
  late String _currentCategoryName;
  bool _hasPhoto = true;
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  // ပြင်ဆင်နေစဉ်အတွင်း expense/income ကို ခြေရာခံရန်
  late bool isExpense;

  @override
  void initState() {
    super.initState();
    _displayAmount = widget.item.amount;
    _displayNote = widget.item.note;
    _currentCategoryName = widget.item.title;
    
    // မူလ amount ထဲက သင်္ကေတကိုကြည့်ပြီး expense လား income လား စစ်ခြင်း
    isExpense = widget.item.type == 'expense';

    // controller တွေထဲကို တန်ဖိုးအဟောင်း ထည့်ပေးထားခြင်း
    // အမှတ်လက္ခဏာ (- / +) တွေ ဖြုတ်ပြီး နံပါတ်သီးသန့် controller ထဲထည့်ရန်
    String cleanAmount = widget.item.amount.replaceAll('-', '').replaceAll('+', '').replaceAll(',', '');
    _amountController = TextEditingController(text: cleanAmount);
    _noteController = TextEditingController(text: _displayNote == "No note" ? "" : _displayNote);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context, true), // ပြန်ထွက်ရင် screen update ဖြစ်အောင် true ပို့ပေးမယ်
        ),
        title: Text(
          _isEditing ? "Edit Transaction" : "Transaction Details",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.black),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top Card Displaying Amount and Category
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: widget.item.color,
                    child: Icon(widget.item.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _currentCategoryName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  
                  // ပြင်ဆင်နေချိန်ဆိုလျှင် TextField ပြပြီး ပုံမှန်ဆိုလျှင် Text ပြပေးမည်
                  _isEditing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DropdownButton<bool>(
                              value: isExpense,
                              items: const [
                                DropdownMenuItem(value: true, child: Text("- (Expense)")),
                                DropdownMenuItem(value: false, child: Text("+ (Income)")),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => isExpense = val);
                              },
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 150,
                              child: TextField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                decoration: const InputDecoration(hintText: "0.00"),
                              ),
                            ),
                          ],
                        )
                      : Text(
                          _displayAmount,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: _displayAmount.startsWith('+') ? Colors.green : Colors.black87,
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Detail Rows Card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    label: "Date & Time",
                    child: Text(widget.item.time, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    label: "Note",
                    child: _isEditing
                        ? SizedBox(
                            width: 200,
                            child: TextField(
                              controller: _noteController,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(hintText: "Enter note..."),
                            ),
                          )
                        : Text(_displayNote, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  if (_hasPhoto) ...[
                    const Divider(height: 24),
                    _buildDetailRow(
                      label: "Photo",
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              'assets/images/logo.jpg',
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image, color: Colors.grey),
                            ),
                          ),
                          if (_isEditing)
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                              onPressed: () => setState(() => _hasPhoto = false),
                            )
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save / Done Button
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    setState(() {
                      String prefix = isExpense ? '-' : '+';
                      String finalAmountStr = _amountController.text.trim().isEmpty ? "0.00" : _amountController.text.trim();
                      
                      _displayAmount = "$prefix$finalAmountStr";
                      _displayNote = _noteController.text.trim().isEmpty ? "No note" : _noteController.text.trim();
                      _isEditing = false; 

                      // 🔥 [အရေးကြီးဆုံးအပိုင်း] widget.item ထဲက data များကို တိုက်ရိုက် update လုပ်ပေးခြင်း
                      widget.item.amount = _displayAmount;
                      widget.item.note = _displayNote;
                      widget.item.type = isExpense ? 'expense' : 'income';
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Changes saved successfully!')),
                    );
                  },
                  child: const Text("Done", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({required String label, required Widget child}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(width: 16),
        Expanded(child: Align(alignment: Alignment.centerRight, child: child)),
      ],
    );
  }
}