import 'package:expense_tracker/models/record_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'category_screen.dart';  
import 'transaction_detail_screen.dart'; // Detail Screen Page အား Import ပြုလုပ်ခြင်း [cite: 63]

class RecordHistoryScreen extends StatefulWidget {
  const RecordHistoryScreen({Key? key}) : super(key: key);

  @override
  State<RecordHistoryScreen> createState() => _RecordHistoryScreenState();
}

class _RecordHistoryScreenState extends State<RecordHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // [cite: 66]
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); 
      }
    });
    _calculateTotals(); // [cite: 67]
  }

  // 💡 စုစုပေါင်း ဝင်ငွေ/ထွက်ငွေများကို ပြန်လည်တွက်ချက်ပေးမည့် လုပ်ဆောင်ချက်
  void _calculateTotals() {
    double income = 0.0;
    double expense = 0.0;
    for (var record in globalRecords) { // [cite: 68]
      String amountStr = record.amount.replaceAll('-', '').replaceAll('+', '').replaceAll(',', ''); // [cite: 68]
      double amountVal = double.tryParse(amountStr) ?? 0.0; // [cite: 69]

      if (record.type == 'income') { // [cite: 69]
        income += amountVal; // [cite: 69]
      } else {
        expense += amountVal; // [cite: 69]
      }
    }

    setState(() {
      _totalIncome = income; // [cite: 70]
      _totalExpense = expense; // [cite: 70]
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // [cite: 70]
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseList = globalRecords.where((t) => t.type == 'expense').toList(); // [cite: 71]
    final incomeList = globalRecords.where((t) => t.type == 'income').toList(); // [cite: 72]
    String currentMonthYear = DateFormat('MMMM - yyyy').format(DateTime.now()); // [cite: 72]

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // [cite: 73]
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context), // [cite: 73]
        ),
        title: const Text(
          'History',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black, size: 22),
            onPressed: () => Navigator.pop(context), // [cite: 73]
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    indicatorColor: const Color(0xFF38BDF8),
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'All'),
                      Tab(text: 'Expense'),
                      Tab(text: 'Income'), // [cite: 73, 74]
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_alt_outlined, color: Colors.black87),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month_outlined, color: Colors.black87),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                      child: Text(
                        currentMonthYear,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [ 
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Income', style: TextStyle(color: Colors.grey, fontSize: 13)), // [cite: 75]
                              const SizedBox(height: 4),
                              Text(
                                NumberFormat('#,##0.00').format(_totalIncome), // [cite: 75]
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Expense', style: TextStyle(color: Colors.grey, fontSize: 13)), // [cite: 75]
                              const SizedBox(height: 4),
                              Text(
                                NumberFormat('#,##0.00').format(_totalExpense), // [cite: 75]
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)), // [cite: 75]
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12), 
                    bottomRight: Radius.circular(12), // [cite: 75, 76]
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTransactionListView(globalRecords),
                      _buildTransactionListView(expenseList),
                      _buildTransactionListView(incomeList), // [cite: 76]
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionListView(List<RecordItem> records) {
    if (records.isEmpty) { // [cite: 77]
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey.shade300), // [cite: 77]
            const SizedBox(height: 12),
            const Text(
              "No records yet",
              style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              "Transactions you add will appear here.",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13), // [cite: 77]
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // 
      itemCount: records.length,
      separatorBuilder: (context, index) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Divider(height: 1, thickness: 0.5, color: Color(0xFFF3F4F6)), // 
      ),
      itemBuilder: (context, index) {
        // နောက်ဆုံးသွင်းထားသော စာရင်းများအား အပေါ်ဆုံးမှ ပြသရန်
        final item = records[records.length - 1 - index]; // 
        final bool isExpense = item.type == 'expense'; // 
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // 
          
          // 🔥 [ပြင်ဆင်ထားသော အဓိက အပိုင်း] 
          // Detail Page မှ true ဖြင့် ပြန်ထွက်လာချိန်တွင် မိုင်ခရိုစက္ကန့်ပိုင်းအတွင်း တွက်ချက်မှုအသစ်များ ပြန်လုပ်ပေးရန်
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionDetailScreen(item: item),
              ),
            );
            
            // Detail Screen မှ Back ခလုတ်နှိပ်၍ ပြန်လာလျှင် စုစုပေါင်းငွေများကို ပြန်တွက်ပြီး UI အား Update လုပ်ပေးခြင်း
            _calculateTotals();
          },
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: Colors.white, size: 22), // 
          ),
          title: Text(
            item.title, // Category Name [cite: 78, 79]
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87), // [cite: 79]
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              item.time, // [cite: 79]
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          trailing: Text(
            item.amount, // [cite: 79]
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isExpense ? Colors.black87 : Colors.green, // [cite: 79, 80]
            ),
          ),
        );
      },
    );
  }
}