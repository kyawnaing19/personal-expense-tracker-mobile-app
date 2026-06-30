import 'package:expense_tracker/features/auth/presentation/screens/MainNavigationScreen.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../bloc/category_bloc.dart'; 
import '../bloc/category_state.dart';
import 'package:expense_tracker/models/category_model.dart'; 

enum CategoryState { view, add, edit, calculator } 

class RecordHistoryScreen extends StatefulWidget {
  // 🎯 onTabChanged callback ကို ထည့်သွင်းခြင်း
  final ValueChanged<int>? onTabChanged;
  const RecordHistoryScreen({Key? key, this.onTabChanged}) : super(key: key);

  @override
  State<RecordHistoryScreen> createState() => _RecordHistoryScreenState();
}

class _RecordHistoryScreenState extends State<RecordHistoryScreen> {
  String _selectedFilter = 'All'; 
  
  // 🎯 ပြင်ဆင်ချက် - တစ်ခုထက်မက ကြိုက်သလောက်ရွေးချယ်မှုကို သိမ်းရန် List စနစ်ပြောင်းလဲခြင်း
  List<String> _selectedFilterCategories = []; 
  
  int _currentTabIndex = 3; 
  CategoryState _currentState = CategoryState.view; 

  @override
  void initState() {
    super.initState();
    BlocProvider.of<TransactionBloc>(context).add(LoadTransactions());
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocBuilder<CategoryBloc, CategoryStateBase>(
          builder: (context, state) {
            List<CategoryItem> availableCategories = [];
            
            if (state is CategoryLoaded) {
              // 🎯 ၁။ အကုန်လုံးကို အရင်ယူမယ်
              availableCategories = state.categories;

              // 🎯 ၂။ Top Tab Filter (`_selectedFilter`) ပေါ်မူတည်ပြီး Category များကို စစ်ထုတ်ခြင်း
              if (_selectedFilter == 'Expense') {
                // Category Model ထဲမှာ type (သို့) ခွဲခြားနိုင်တဲ့ variable အပေါ်မူတည်ပြီး စစ်ထုတ်ပါမယ်
                availableCategories = availableCategories
                    .where((cat) => cat.type.toLowerCase() == 'expense')
                    .toList();
              } else if (_selectedFilter == 'Income') {
                availableCategories = availableCategories
                    .where((cat) => cat.type.toLowerCase() == 'income')
                    .toList();
              }
            }

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 24),
                      const Text(
                        "Category Type",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  availableCategories.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            "No categories available for this type", 
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : StatefulBuilder(
                          builder: (context, setSheetState) {
                            return SizedBox(
                              width: double.infinity,
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: availableCategories.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,         
                                  mainAxisSpacing: 12,       
                                  crossAxisSpacing: 10,      
                                  childAspectRatio: 2.5,     
                                ),
                                itemBuilder: (context, index) {
                                  final category = availableCategories[index];
                                  bool isSelected = _selectedFilterCategories.contains(category.name);

                                  return InkWell(
                                    onTap: () {
                                      setSheetState(() {
                                        if (isSelected) {
                                          _selectedFilterCategories.remove(category.name);
                                        } else {
                                          _selectedFilterCategories.add(category.name);
                                        }
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      alignment: Alignment.center, 
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFE9E3F8),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        category.name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : const Color(0xFF1F2937),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {}); 
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
                      ),
                      child: const Text(
                        "OK",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE7F6), 
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                const SizedBox(height: 16),
                _buildTopHeader(),
                const SizedBox(height: 16),
                _buildFilterRow(),
                const SizedBox(height: 20),
                _buildTransactionCardContainer(), 
                const SizedBox(height: 24), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildTopHeader() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       GestureDetector(
  //         onTap: () => Navigator.pop(context),
  //         child: Container(
  //           padding: const EdgeInsets.all(10),
  //           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
  //           child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black),
  //         ),
  //       ),
  //       const Text(
  //         "Transaction History",
  //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
  //       ),
  //       Container(
  //         padding: const EdgeInsets.all(10),
  //         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
  //         child: const Icon(Icons.close, size: 18, color: Colors.black),
  //       ),
  //     ],
  //   );
  // }

 Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            // 🎯 MainNavigationScreen ရဲ့ onTabChanged ဆီကို Index 0 (Home) လို့ လှမ်းပို့ပေးခြင်းဖြစ်ပါတယ်
            if (widget.onTabChanged != null) {
              widget.onTabChanged!(0); 
            }
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black),
          ),
        ),
        const Text(
          "Transaction History",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(width: 40), // ညာဘက်အချိုးညီအောင် နေရာချန်ခြင်း
      ],
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: ['All', 'Expense', 'Income'].map((tab) {
                bool isSelected = _selectedFilter == tab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = tab),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF7C3AED) : Colors.transparent, 
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tab,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _showFilterBottomSheet(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Icon(
              Icons.filter_alt_outlined, 
              color: _selectedFilterCategories.isNotEmpty ? const Color(0xFF7C3AED) : Colors.black54, 
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.calendar_month_outlined, color: Colors.black54, size: 20),
        ),
      ],
    );
  }

  Widget _buildTransactionCardContainer() {
    return BlocBuilder<TransactionBloc, TransactionStateBase>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)));
        }
        if (state is TransactionError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        
        List<TransactionItem> list = [];
        if (state is TransactionLoaded) {
          // 🎯 ပြင်ဆင်ချက် - ဒေတာများကို ပွားယူပြီးမှ စီစဥ်ရန်
          list = List.from(state.transactions);
        }

        if (_selectedFilter == 'Expense') {
          list = list.where((t) => t.type == 'expense').toList();
        } else if (_selectedFilter == 'Income') {
          list = list.where((t) => t.type == 'income').toList();
        }

        // 🎯 ပြင်ဆင်ချက် - Multi-category Filter Logic (ရွေးချယ်ထားသော Category မျိုးစုံပါဝင်မှုရှိမရှိ စစ်ထုတ်ခြင်း)
        if (_selectedFilterCategories.isNotEmpty) {
          final categoryState = context.read<CategoryBloc>().state;
          if (categoryState is CategoryLoaded) {
            list = list.where((tx) {
              final matchedCategory = categoryState.categories.firstWhere(
                (cat) => cat.id == tx.categoryId,
                orElse: () => categoryState.categories.first, 
              );
              return _selectedFilterCategories.contains(matchedCategory.name);
            }).toList();
          }
        }

        // 🎯 ပြင်ဆင်ချက် - image_a39510.jpg အတိုင်း အသစ်ဆုံးထည့်လိုက်သော ဒေတာကို အပေါ်ဆုံးတွင် ထားရှိရန်
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        double totalIncome = 0;
        double totalExpense = 0;
        for (var item in list) {
          if (item.type == 'income') totalIncome += item.amount;
          if (item.type == 'expense') totalExpense += item.amount;
        }

        final formatter = NumberFormat('#,##0');

        String currentMonthYear = DateFormat('MMMM - yyyy').format(DateTime.now());
        if (list.isNotEmpty) {
          currentMonthYear = DateFormat('MMMM - yyyy').format(list.first.createdAt);
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24), 
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎯 ပြင်ဆင်ချက် - ရွေးချယ်ထားသမျှ Categories Chip အားလုံးကို အတန်းလိုက် Dynamic ဖော်ပြပေးရန်
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(currentMonthYear, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      if (_selectedFilterCategories.isNotEmpty)
                        GestureDetector(
                          onTap: () => setState(() => _selectedFilterCategories.clear()),
                          child: const Text("Clear All", style: TextStyle(color: Color(0xFF7C3AED), fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  if (_selectedFilterCategories.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _selectedFilterCategories.map((catName) {
                        return Chip(
                          label: Text(catName, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                          backgroundColor: const Color(0xFF7C3AED),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          deleteIcon: const Icon(Icons.cancel, color: Colors.white, size: 14),
                          onDeleted: () {
                            setState(() {
                              _selectedFilterCategories.remove(catName);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Income", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(formatter.format(totalIncome), style: const TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Expense", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(formatter.format(totalExpense), style: const TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              list.isEmpty 
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: Text("No transactions found", style: TextStyle(color: Colors.grey))),
                  )
                : ListView.separated(
                    shrinkWrap: true, 
                    physics: const NeverScrollableScrollPhysics(), 
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const Divider(color: Color(0xFFF3F4F6), height: 24),
                    itemBuilder: (context, index) {
                      final tx = list[index];
                      final isExpense = tx.type == 'expense';

                      String finalCategoryName = "Unknown";
                      IconData finalIcon = Icons.local_offer_outlined;
                      Color finalColor = Colors.indigo;

                      final categoryState = context.read<CategoryBloc>().state;
                      if (categoryState is CategoryLoaded) {
                        final matchedCategory = categoryState.categories.firstWhere(
                          (cat) => cat.id == tx.categoryId,
                          orElse: () => categoryState.categories.first, 
                        );
                        
                        finalCategoryName = matchedCategory.name; 
                        finalIcon = matchedCategory.icon; 
                        finalColor = matchedCategory.color;

                        String colorHex = '#${matchedCategory.color.value.toRadixString(16).substring(2)}';
                        colorHex = colorHex.replaceAll('#', ''); 
                        finalColor = Color(int.parse('0xFF$colorHex'));
                      }

                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: finalColor,
                            child: Icon(finalIcon, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  finalCategoryName, 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                if (tx.note.isNotEmpty && tx.note != "No note")
                                  Text(
                                    tx.note,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.black54, fontSize: 13, fontStyle: FontStyle.italic),
                                  ),
                                const SizedBox(height: 2),
                                // 🎯 ပြင်ဆင်ချက် - .toLocal() သုံး၍ ဖုန်းစက်တွင်း ဒေသစံတော်ချိန်ကို တိကျမှန်ကန်စွာ ဖော်ပြခြင်း
                                Text(
                                  "${DateFormat('dd/MM').format(tx.createdAt.toLocal())}  ${DateFormat('HH:mm:ss').format(tx.createdAt.toLocal())}",
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                isExpense ? "-${formatter.format(tx.amount)}" : "+${formatter.format(tx.amount)}",
                                style: TextStyle(
                                  color: isExpense ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isExpense ? const Color(0xFFFFE4E6) : const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                                      size: 10,
                                      color: isExpense ? Colors.red : Colors.green,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      tx.type, 
                                      style: TextStyle(
                                        color: isExpense ? Colors.red : Colors.green,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
            ],
          ),
        );
      },
    );
  }
}