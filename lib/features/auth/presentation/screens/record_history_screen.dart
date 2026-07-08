// import 'package:expense_tracker/features/auth/presentation/screens/transaction_detail_screen.dart';
// import 'package:expense_tracker/models/transaction_model.dart';
// import 'package:flutter/cupertino.dart'; 
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import '../bloc/transaction_bloc.dart';
// import '../bloc/transaction_event.dart';
// import '../bloc/transaction_state.dart';
// import '../bloc/category_bloc.dart';
// import '../bloc/category_state.dart';
// import 'package:expense_tracker/models/category_model.dart'; 

// class RecordHistoryScreen extends StatefulWidget {
//   final ValueChanged<int>? onTabChanged;
//   const RecordHistoryScreen({Key? key, this.onTabChanged}) : super(key: key);

//   @override
//   State<RecordHistoryScreen> createState() => _RecordHistoryScreenState();
// }

// class _RecordHistoryScreenState extends State<RecordHistoryScreen> {
//   String _selectedFilter = 'All'; 
//   List<String> _selectedFilterCategories = [];
//   String _calendarFilterType = 'none'; // 'none', 'date', 'period'

//   int _selectedYear = DateTime.now().year;
//   int _selectedMonth = DateTime.now().month;

//   DateTime? _startDate;
//   DateTime? _endDate;

//   final Color primaryPurple = const Color(0xFF7F3DFF); 
//   final Color lightPurpleBg = const Color(0xFFEEE5FF);

//   String _activePeriodShortcut = 'none';

//   @override
//   void initState() {
//     super.initState();
//     BlocProvider.of<TransactionBloc>(context).add(LoadTransactions());
//   }

//   void _showCalendarFilterDialog() {
//     String tempFilterType = _calendarFilterType == 'none' ? 'date' : _calendarFilterType;
//     int tempYear = _selectedYear;
//     int tempMonth = _selectedMonth;
//     DateTime? tempStart = _startDate;
//     DateTime? tempEnd = _endDate;
//     String tempActiveShortcut = _activePeriodShortcut;

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             bool isSelectByDate = tempFilterType == 'date';

//             return AlertDialog(
//               backgroundColor: Colors.white,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//               content: Container(
//                 width: MediaQuery.of(context).size.width * 0.95,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         _buildDialogTabButton("Select by Date", isSelectByDate, () => setDialogState(() => tempFilterType = 'date')),
//                         _buildDialogTabButton("Select by Period", !isSelectByDate, () => setDialogState(() => tempFilterType = 'period')),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     const Divider(color: Color(0xFFE5E7EB)),
//                     const SizedBox(height: 12),

//                     if (isSelectByDate) ...[
//                       SizedBox(
//                         height: 140,
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: CupertinoPicker(
//                                 scrollController: FixedExtentScrollController(initialItem: tempYear - 2020),
//                                 itemExtent: 36,
//                                 onSelectedItemChanged: (index) => tempYear = 2020 + index,
//                                 children: List.generate(15, (index) => Center(child: Text("${2020 + index}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)))),
//                               ),
//                             ),
//                             Expanded(
//                               child: CupertinoPicker(
//                                 scrollController: FixedExtentScrollController(initialItem: tempMonth - 1),
//                                 itemExtent: 36,
//                                 onSelectedItemChanged: (index) => tempMonth = index + 1,
//                                 children: List.generate(12, (index) => Center(child: Text((index + 1).toString().padLeft(2, '0'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)))),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],

//                     if (!isSelectByDate) ...[
//                       const Text("Transaction Time", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
//                       const SizedBox(height: 10),
//                       SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         physics: const BouncingScrollPhysics(),
//                         child: Row(
//                           children: [
//                             _buildQuickPeriodButton("Last Month", tempActiveShortcut == 'last_month', () {
//                               setDialogState(() {
//                                 tempActiveShortcut = 'last_month';
//                                 tempEnd = DateTime.now();
//                                 tempStart = DateTime.now().subtract(const Duration(days: 30));
//                               });
//                             }),
//                             const SizedBox(width: 8),
//                             _buildQuickPeriodButton("Last 3 Month", tempActiveShortcut == 'last_3_months', () {
//                               setDialogState(() {
//                                 tempActiveShortcut = 'last_3_months';
//                                 tempEnd = DateTime.now();
//                                 tempStart = DateTime.now().subtract(const Duration(days: 90));
//                               });
//                             }),
//                             const SizedBox(width: 8),
//                             _buildQuickPeriodButton("Last 1 year", tempActiveShortcut == 'last_year', () {
//                               setDialogState(() {
//                                 tempActiveShortcut = 'last_year';
//                                 tempEnd = DateTime.now();
//                                 tempStart = DateTime.now().subtract(const Duration(days: 365));
//                               });
//                             }),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       const Text("Select by Period", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
//                       const SizedBox(height: 10),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _buildTimePickerBox(tempStart != null ? DateFormat('dd/MM/yyyy').format(tempStart!) : "Start Time", () async {
//                               final picked = await showDatePicker(context: context, initialDate: tempStart ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now(), builder: (context, child) => _buildDatePickerTheme(child));
//                               if (picked != null) setDialogState(() { tempActiveShortcut = 'none'; tempStart = picked; });
//                             }),
//                           ),
//                           const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("to", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54))),
//                           Expanded(
//                             child: _buildTimePickerBox(tempEnd != null ? DateFormat('dd/MM/yyyy').format(tempEnd!) : "End Time", () async {
//                               final picked = await showDatePicker(context: context, initialDate: tempEnd ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now(), builder: (context, child) => _buildDatePickerTheme(child));
//                               if (picked != null) setDialogState(() { tempActiveShortcut = 'none'; tempEnd = picked; });
//                             }),
//                           ),
//                           if (tempStart != null || tempEnd != null)
//                             IconButton(icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20), onPressed: () => setDialogState(() { tempActiveShortcut = 'none'; tempStart = null; tempEnd = null; })),
//                         ],
//                       ),
//                     ],

//                     const SizedBox(height: 24),
//                     SizedBox(
//                       width: double.infinity,
//                       height: 46,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           setState(() {
//                             _calendarFilterType = tempFilterType;
//                             _selectedYear = tempYear;
//                             _selectedMonth = tempMonth;
//                             _startDate = tempStart;
//                             _endDate = tempEnd;
//                             _activePeriodShortcut = tempActiveShortcut;
//                           });
//                           Navigator.pop(context);
//                         },
//                         style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
//                         child: const Text("Ok", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildDatePickerTheme(Widget? child) {
//     return Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: primaryPurple, onPrimary: Colors.white, onSurface: Colors.black), textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: primaryPurple))), child: child!);
//   }

//   Widget _buildDialogTabButton(String text, bool isActive, VoidCallback onTap) {
//     return GestureDetector(onTap: onTap, child: Column(mainAxisSize: MainAxisSize.min, children: [Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isActive ? primaryPurple : Colors.black87)), const SizedBox(height: 4), Container(height: 3, width: 70, decoration: BoxDecoration(color: isActive ? primaryPurple : Colors.transparent, borderRadius: BorderRadius.circular(2)))]));
//   }

//   Widget _buildQuickPeriodButton(String label, bool isActive, VoidCallback onTap) {
//     return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: isActive ? primaryPurple : lightPurpleBg, borderRadius: BorderRadius.circular(12)), child: Text(label, style: TextStyle(color: isActive ? Colors.white : primaryPurple, fontSize: 13, fontWeight: FontWeight.w600))));
//   }

//   Widget _buildTimePickerBox(String text, VoidCallback onTap) {
//     return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10), alignment: Alignment.center, decoration: BoxDecoration(color: lightPurpleBg, borderRadius: BorderRadius.circular(12), border: text.contains('/') ? Border.all(color: primaryPurple, width: 1) : null), child: Text(text, style: TextStyle(color: text.contains('/') ? primaryPurple : Colors.grey, fontSize: 13, fontWeight: FontWeight.w500))));
//   }

//   void _showFilterBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return BlocBuilder<CategoryBloc, CategoryStateBase>(
//           builder: (context, state) {
//             List<CategoryItem> availableCategories = [];
//             if (state is CategoryLoaded) {
//               availableCategories = state.categories;
//               if (_selectedFilter == 'Expense') {
//                 availableCategories = availableCategories.where((cat) => cat.type.toLowerCase() == 'expense').toList();
//               } else if (_selectedFilter == 'Income') {
//                 availableCategories = availableCategories.where((cat) => cat.type.toLowerCase() == 'income').toList();
//               }
//             }

//             return Container(
//               padding: const EdgeInsets.all(24),
//               decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const SizedBox(width: 24),
//                       const Text("Category Type", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
//                       IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   availableCategories.isEmpty
//                       ? const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text("No categories available for this type", style: TextStyle(color: Colors.grey)))
//                       : StatefulBuilder(
//                           builder: (context, setSheetState) {
//                             return SizedBox(
//                               width: double.infinity,
//                               child: GridView.builder(
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 itemCount: availableCategories.length,
//                                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 10, childAspectRatio: 2.5),
//                                 itemBuilder: (context, index) {
//                                   final category = availableCategories[index];
//                                   bool isSelected = _selectedFilterCategories.contains(category.name);

//                                   return InkWell(
//                                     onTap: () {
//                                       setSheetState(() {
//                                         if (isSelected) { _selectedFilterCategories.remove(category.name); } else { _selectedFilterCategories.add(category.name); }
//                                       });
//                                     },
//                                     borderRadius: BorderRadius.circular(8),
//                                     child: Container(
//                                       alignment: Alignment.center, 
//                                       decoration: BoxDecoration(color: isSelected ? primaryPurple : lightPurpleBg, borderRadius: BorderRadius.circular(8)),
//                                       child: Text(category.name, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF1F2937), fontWeight: FontWeight.w600, fontSize: 13)),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             );
//                           },
//                         ),
//                   const SizedBox(height: 32),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 48,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         setState(() {}); 
//                         Navigator.pop(context);
//                       },
//                       style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
//                       child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFEDE7F6), 
//       body: SafeArea(
//         // ⭐ [အဓိကပြင်ဆင်ချက်] BlocBuilder အစား BlocConsumer ကိုသုံးပြီး ActionSuccess ဖြစ်တာနဲ့ ဒေတာချက်ချင်းပြန်ဆွဲခိုင်းပါတယ်
//         child: BlocConsumer<TransactionBloc, TransactionStateBase>(
//           listener: (context, state) {
//             if (state is TransactionActionSuccess) {
//               // Edit သို့မဟုတ် Delete လုပ်လို့ အောင်မြင်တာနဲ့ နောက်ကွယ်ကနေ ဒေတာအသစ်ကို ချက်ချင်း ပြန်ဆွဲခိုင်းမယ်
//               BlocProvider.of<TransactionBloc>(context).add(LoadTransactions());
//             }
//           },
//           builder: (context, state) {
//             if (state is TransactionLoading) {
//               return Center(child: CircularProgressIndicator(color: primaryPurple));
//             }
//             if (state is TransactionError) {
//               return Center(child: Text('Error: ${state.message}'));
//             }

//             List<TransactionItem> rawList = [];
//             // Loading ပြန်ဖြစ်နေချိန် သို့မဟုတ် ActionSuccess ခဏဖြစ်ချိန်မှာ Screen ပေါ်က ဒေတာဟောင်းတွေ ချက်ချင်း ပျောက်မသွားအောင် စစ်ထုတ်ပေးထားပါတယ်
//             if (state is TransactionLoaded) {
//               rawList = List.from(state.transactions);
//             }

//             // 🎯 1. All / Expense / Income Type Filter စစ်ထုတ်ခြင်း
//             if (_selectedFilter != 'All') {
//               rawList = rawList.where((tx) => tx.type.toLowerCase() == _selectedFilter.toLowerCase()).toList();
//             }

//             // 🎯 2. Category Filter စစ်ထုတ်ခြင်း
//             if (_selectedFilterCategories.isNotEmpty) {
//               final categoryState = context.read<CategoryBloc>().state;
//               if (categoryState is CategoryLoaded) {
//                 rawList = rawList.where((tx) {
//                   final cat = categoryState.categories.firstWhere((c) => c.id == tx.categoryId, orElse: () => CategoryItem(id: '', name: '', icon: Icons.help, color: Colors.grey, type: ''));
//                   return _selectedFilterCategories.contains(cat.name);
//                 }).toList();
//               }
//             }

//             // 🎯 3. Calendar & Period Filter စစ်ထုတ်ခြင်း
//             if (_calendarFilterType == 'date') {
//               rawList = rawList.where((tx) => tx.createdAt.year == _selectedYear && tx.createdAt.month == _selectedMonth).toList();
//             } else if (_calendarFilterType == 'period' && _startDate != null && _endDate != null) {
//               DateTime startClean = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
//               DateTime endClean = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
//               rawList = rawList.where((tx) => tx.createdAt.isAfter(startClean) && tx.createdAt.isBefore(endClean)).toList();
//             }

//             // ရက်စွဲအလိုက် အရင်ဆုံး အစီအစဉ်စီပါမယ်
//             rawList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

//             // 🎯 ဒေတာများကို လအလိုက် (Year-Month) ပုံစံဖြင့် Group ဖွဲ့ခွဲထုတ်ခြင်း
//             Map<String, List<TransactionItem>> groupedTransactions = {};
//             for (var tx in rawList) {
//               String monthKey = DateFormat('MMMM - yyyy').format(tx.createdAt);
//               if (groupedTransactions[monthKey] == null) {
//                 groupedTransactions[monthKey] = [];
//               }
//               groupedTransactions[monthKey]!.add(tx);
//             }

//             return SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 16),
//                     _buildTopHeader(),
//                     const SizedBox(height: 16),
//                     _buildFilterRow(),
//                     const SizedBox(height: 12),
                    
//                     // Chip Filters များပြသရန်နေရာ
//                     if (_selectedFilterCategories.isNotEmpty || _calendarFilterType != 'none')
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: Wrap(
//                               spacing: 6,
//                               runSpacing: 6,
//                               children: [
//                                 if (_calendarFilterType == 'date')
//                                   Chip(label: Text(DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth)), style: const TextStyle(color: Colors.white, fontSize: 11)), backgroundColor: primaryPurple),
//                                 if (_calendarFilterType == 'period' && _startDate != null && _endDate != null)
//                                   Chip(label: Text("${DateFormat('dd/MM').format(_startDate!)} - ${DateFormat('dd/MM').format(_endDate!)}", style: const TextStyle(color: Colors.white, fontSize: 11)), backgroundColor: primaryPurple),
//                                 ..._selectedFilterCategories.map((catName) => Chip(
//                                   label: Text(catName, style: const TextStyle(color: Colors.white, fontSize: 11)),
//                                   backgroundColor: primaryPurple,
//                                   onDeleted: () => setState(() => _selectedFilterCategories.remove(catName)),
//                                 )),
//                               ],
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: () => setState(() {
//                               _selectedFilterCategories.clear();
//                               _calendarFilterType = 'none';
//                               _startDate = null;
//                               _endDate = null;
//                             }),
//                             child: Text("Clear Filter", style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold)),
//                           )
//                         ],
//                       ),
                    
//                     const SizedBox(height: 8),

//                     // ဒေတာမရှိရင် ပြသမည့်နေရာ
//                     groupedTransactions.isEmpty 
//                         ? (state is TransactionLoaded 
//                             ? Container(
//                                 width: double.infinity,
//                                 margin: const EdgeInsets.only(top: 32),
//                                 padding: const EdgeInsets.all(24),
//                                 decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
//                                 child: const Center(child: Text("No transactions found", style: TextStyle(color: Colors.grey, fontSize: 15))),
//                               )
//                             : Center(child: CircularProgressIndicator(color: primaryPurple))) // API ကနေ Load လုပ်နေတုန်း ခဏစောင့်ခိုင်းမယ်
//                         : ListView.builder(
//                             shrinkWrap: true,
//                             physics: const NeverScrollableScrollPhysics(),
//                             itemCount: groupedTransactions.keys.length,
//                             itemBuilder: (context, groupIndex) {
//                               String monthHeader = groupedTransactions.keys.elementAt(groupIndex);
//                               List<TransactionItem> txList = groupedTransactions[monthHeader]!;
                              
//                               double monthIncome = 0;
//                               double monthExpense = 0;
//                               for (var item in txList) {
//                                 if (item.type == 'income') monthIncome += item.amount;
//                                 if (item.type == 'expense') monthExpense += item.amount;
//                               }
//                               return _buildMonthCardGroup(monthHeader, txList, monthIncome, monthExpense);
//                             },
//                           ),
//                     const SizedBox(height: 32),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildMonthCardGroup(String headerTitle, List<TransactionItem> items, double income, double expense) {
//     final formatter = NumberFormat('#,##0');
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(headerTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Income", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)), const SizedBox(height: 4), Text(formatter.format(income), style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold))]),
//               Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text("Expense", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)), const SizedBox(height: 4), Text(formatter.format(expense), style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold))]),
//             ],
//           ),
//           const SizedBox(height: 12),
//           const Divider(color: Color(0xFFF3F4F6)),
//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: items.length,
//             separatorBuilder: (context, index) => const Divider(color: Color(0xFFF3F4F6), height: 24),
//             itemBuilder: (context, idx) {
//               final tx = items[idx];
//               final isExpense = tx.type == 'expense';
//               String finalCategoryName = "Unknown";
//               IconData finalIcon = Icons.local_offer_outlined;
//               Color finalColor = Colors.indigo;

//               final categoryState = context.read<CategoryBloc>().state;
//               if (categoryState is CategoryLoaded) {
//                 final matchedCategory = categoryState.categories.firstWhere((cat) => cat.id == tx.categoryId, orElse: () => categoryState.categories.first);
//                 finalCategoryName = matchedCategory.name;
//                 finalIcon = matchedCategory.icon;
//                 finalColor = matchedCategory.color;
//               }
//               return GestureDetector(
//                 behavior: HitTestBehavior.opaque,
//                 onTap: () async {
//                   // Detail Screen ကိုသွားမယ်၊ ပြန်လာရင် Result ပါသည်ဖြစ်စေ၊ မပါသည်ဖြစ်စေ ဒေတာသေချာ Refresh လုပ်ပေးထားပါတယ်
//                   final result = await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => TransactionDetailScreen(
//                         transaction: tx,
//                         categoryName: finalCategoryName,
//                         categoryIcon: finalIcon,
//                         categoryColor: finalColor
//                       )
//                     )
//                   );
//                   if (context.mounted) {
//                     BlocProvider.of<TransactionBloc>(context).add(LoadTransactions());
//                   }
//                 },
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 24,
//                       backgroundColor: finalColor,
//                       child: Icon(finalIcon, color: Colors.white, size: 22)
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(finalCategoryName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//                           const SizedBox(height: 2),
//                           if (tx.note.isNotEmpty && tx.note != "No note") Text(tx.note, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 13, fontStyle: FontStyle.italic)),
//                           const SizedBox(height: 2),
//                           Text(DateFormat('dd/MM HH:mm').format(tx.createdAt.toLocal()), style: const TextStyle(color: Colors.grey, fontSize: 12)),
//                         ],
//                       ),
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(isExpense ? "-${formatter.format(tx.amount)}" : "+${formatter.format(tx.amount)}", style: TextStyle(color: isExpense ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
//                         const SizedBox(height: 4),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//                           decoration: BoxDecoration(color: isExpense ? const Color(0xFFFFE4E6) : const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(12)),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(isExpense ? Icons.arrow_downward : Icons.arrow_upward, size: 10, color: isExpense ? Colors.red : Colors.green),
//                               const SizedBox(width: 2),
//                               Text(tx.type, style: TextStyle(color: isExpense ? Colors.red : Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTopHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         GestureDetector(
//           onTap: () { if (widget.onTabChanged != null) widget.onTabChanged!(0); },
//           child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black))
//         ),
//         const Text("Transaction History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
//         const SizedBox(width: 36),
//       ],
//     );
//   }

//   Widget _buildFilterRow() {
//     return Row(
//       children: [
//         Expanded(
//           child: Container(
//             padding: const EdgeInsets.all(4),
//             decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
//             child: Row(
//               children: ['All', 'Expense', 'Income'].map((tab) {
//                 bool isSelected = _selectedFilter == tab;
//                 return Expanded(
//                   child: GestureDetector(
//                     onTap: () => setState(() => _selectedFilter = tab),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       decoration: BoxDecoration(color: isSelected ? primaryPurple : Colors.transparent, borderRadius: BorderRadius.circular(8)),
//                       child: Text(tab, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.grey)),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ),
//         const SizedBox(width: 8),
//         GestureDetector(onTap: () => _showFilterBottomSheet(context), child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _selectedFilterCategories.isNotEmpty ? primaryPurple : Colors.white, borderRadius: BorderRadius.circular(12)), child: Icon(Icons.filter_alt_outlined, color: _selectedFilterCategories.isNotEmpty ? Colors.white : Colors.black54, size: 20))),
//         const SizedBox(width: 8),
//         GestureDetector(onTap: _showCalendarFilterDialog, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _calendarFilterType != 'none' ? primaryPurple : Colors.white, borderRadius: BorderRadius.circular(12)), child: Icon(Icons.calendar_month_outlined, color: _calendarFilterType != 'none' ? Colors.white : Colors.black54, size: 20))),
//       ],
//     );
//   }
// }


import 'package:expense_tracker/features/auth/presentation/screens/transaction_detail_screen.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:flutter/cupertino.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_state.dart';
import 'package:expense_tracker/models/category_model.dart'; 

class RecordHistoryScreen extends StatefulWidget {
  final ValueChanged<int>? onTabChanged;
  const RecordHistoryScreen({Key? key, this.onTabChanged}) : super(key: key);

  @override
  State<RecordHistoryScreen> createState() => _RecordHistoryScreenState();
}

class _RecordHistoryScreenState extends State<RecordHistoryScreen> {
  String _selectedFilter = 'All'; 
  List<String> _selectedFilterCategories = [];
  String _calendarFilterType = 'none'; // 'none', 'date', 'period'

  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  DateTime? _startDate;
  DateTime? _endDate;

  final Color primaryPurple = const Color(0xFF7F3DFF); 
  final Color lightPurpleBg = const Color(0xFFEEE5FF);

  String _activePeriodShortcut = 'none';

  @override
  void initState() {
    super.initState();
    BlocProvider.of<TransactionBloc>(context).add(LoadTransactions());
  }

  void _showCalendarFilterDialog() {
    String tempFilterType = _calendarFilterType == 'none' ? 'date' : _calendarFilterType;
    int tempYear = _selectedYear;
    int tempMonth = _selectedMonth;
    DateTime? tempStart = _startDate;
    DateTime? tempEnd = _endDate;
    String tempActiveShortcut = _activePeriodShortcut;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool isSelectByDate = tempFilterType == 'date';

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildDialogTabButton("Select by Date", isSelectByDate, () => setDialogState(() => tempFilterType = 'date')),
                        _buildDialogTabButton("Select by Period", !isSelectByDate, () => setDialogState(() => tempFilterType = 'period')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 12),

                    if (isSelectByDate) ...[
                      SizedBox(
                        height: 140,
                        child: Row(
                          children: [
                            Expanded(
                              child: CupertinoPicker(
                                scrollController: FixedExtentScrollController(initialItem: tempYear - 2020),
                                itemExtent: 36,
                                onSelectedItemChanged: (index) => tempYear = 2020 + index,
                                children: List.generate(15, (index) => Center(child: Text("${2020 + index}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)))),
                              ),
                            ),
                            Expanded(
                              child: CupertinoPicker(
                                scrollController: FixedExtentScrollController(initialItem: tempMonth - 1),
                                itemExtent: 36,
                                onSelectedItemChanged: (index) => tempMonth = index + 1,
                                children: List.generate(12, (index) => Center(child: Text((index + 1).toString().padLeft(2, '0'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (!isSelectByDate) ...[
                      const Text("Transaction Time", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _buildQuickPeriodButton("Last Month", tempActiveShortcut == 'last_month', () {
                              setDialogState(() {
                                tempActiveShortcut = 'last_month';
                                tempEnd = DateTime.now();
                                tempStart = DateTime.now().subtract(const Duration(days: 30));
                              });
                            }),
                            const SizedBox(width: 8),
                            _buildQuickPeriodButton("Last 3 Month", tempActiveShortcut == 'last_3_months', () {
                              setDialogState(() {
                                tempActiveShortcut = 'last_3_months';
                                tempEnd = DateTime.now();
                                tempStart = DateTime.now().subtract(const Duration(days: 90));
                              });
                            }),
                            const SizedBox(width: 8),
                            _buildQuickPeriodButton("Last 1 year", tempActiveShortcut == 'last_year', () {
                              setDialogState(() {
                                tempActiveShortcut = 'last_year';
                                tempEnd = DateTime.now();
                                tempStart = DateTime.now().subtract(const Duration(days: 365));
                              });
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text("Select by Period", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimePickerBox(tempStart != null ? DateFormat('dd/MM/yyyy').format(tempStart!) : "Start Time", () async {
                              final picked = await showDatePicker(context: context, initialDate: tempStart ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now(), builder: (context, child) => _buildDatePickerTheme(child));
                              if (picked != null) setDialogState(() { tempActiveShortcut = 'none'; tempStart = picked; });
                            }),
                          ),
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("to", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54))),
                          Expanded(
                            child: _buildTimePickerBox(tempEnd != null ? DateFormat('dd/MM/yyyy').format(tempEnd!) : "End Time", () async {
                              final picked = await showDatePicker(context: context, initialDate: tempEnd ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now(), builder: (context, child) => _buildDatePickerTheme(child));
                              if (picked != null) setDialogState(() { tempActiveShortcut = 'none'; tempEnd = picked; });
                            }),
                          ),
                          if (tempStart != null || tempEnd != null)
                            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20), onPressed: () => setDialogState(() { tempActiveShortcut = 'none'; tempStart = null; tempEnd = null; })),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _calendarFilterType = tempFilterType;
                            _selectedYear = tempYear;
                            _selectedMonth = tempMonth;
                            _startDate = tempStart;
                            _endDate = tempEnd;
                            _activePeriodShortcut = tempActiveShortcut;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        child: const Text("Ok", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDatePickerTheme(Widget? child) {
    return Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: primaryPurple, onPrimary: Colors.white, onSurface: Colors.black), textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: primaryPurple))), child: child!);
  }

  Widget _buildDialogTabButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Column(mainAxisSize: MainAxisSize.min, children: [Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isActive ? primaryPurple : Colors.black87)), const SizedBox(height: 4), Container(height: 3, width: 70, decoration: BoxDecoration(color: isActive ? primaryPurple : Colors.transparent, borderRadius: BorderRadius.circular(2)))]));
  }

  Widget _buildQuickPeriodButton(String label, bool isActive, VoidCallback onTap) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: isActive ? primaryPurple : lightPurpleBg, borderRadius: BorderRadius.circular(12)), child: Text(label, style: TextStyle(color: isActive ? Colors.white : primaryPurple, fontSize: 13, fontWeight: FontWeight.w600))));
  }

  Widget _buildTimePickerBox(String text, VoidCallback onTap) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10), alignment: Alignment.center, decoration: BoxDecoration(color: lightPurpleBg, borderRadius: BorderRadius.circular(12), border: text.contains('/') ? Border.all(color: primaryPurple, width: 1) : null), child: Text(text, style: TextStyle(color: text.contains('/') ? primaryPurple : Colors.grey, fontSize: 13, fontWeight: FontWeight.w500))));
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // Cap the sheet at roughly half the screen instead of letting it
      // grow to fill the whole screen when there are many categories.
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
      builder: (context) {
        return BlocBuilder<CategoryBloc, CategoryStateBase>(
          builder: (context, state) {
            List<CategoryItem> availableCategories = [];
            if (state is CategoryLoaded) {
              availableCategories = state.categories;
              if (_selectedFilter == 'Expense') {
                availableCategories = availableCategories.where((cat) => cat.type.toLowerCase() == 'expense').toList();
              } else if (_selectedFilter == 'Income') {
                availableCategories = availableCategories.where((cat) => cat.type.toLowerCase() == 'income').toList();
              }
            }

            return Container(
              // Sheet background stays plain white, as requested — only the
              // grid items themselves change from text pills to icon +
              // name, matching the mockup.
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 24),
                      const Text("Category Type", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                      IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // The grid scrolls inside this fixed space instead of
                  // pushing the sheet's own height out to fit every item.
                  Expanded(
                    child: availableCategories.isEmpty
                        ? const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text("No categories available for this type", style: TextStyle(color: Colors.grey)))
                        : StatefulBuilder(
                            builder: (context, setSheetState) {
                              return GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: availableCategories.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 20,
                                  crossAxisSpacing: 10,
                                  // Vertical (icon over name) cells need a
                                  // taller-than-wide ratio, unlike the old
                                  // horizontal text-pill layout.
                                  childAspectRatio: 0.8,
                                ),
                                itemBuilder: (context, index) {
                                  final category = availableCategories[index];
                                  bool isSelected = _selectedFilterCategories.contains(category.name);

                                  return InkWell(
                                    onTap: () {
                                      setSheetState(() {
                                        if (isSelected) { _selectedFilterCategories.remove(category.name); } else { _selectedFilterCategories.add(category.name); }
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: isSelected ? Border.all(color: primaryPurple, width: 2.5) : null,
                                          ),
                                          child: CircleAvatar(
                                            radius: 26,
                                            backgroundColor: category.color,
                                            child: Icon(category.icon, color: Colors.white, size: 24),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          category.name,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isSelected ? primaryPurple : const Color(0xFF1F2937),
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {}); 
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
        child: BlocConsumer<TransactionBloc, TransactionStateBase>(
          listener: (context, state) {
            if (state is TransactionActionSuccess) {
              BlocProvider.of<TransactionBloc>(context).add(LoadTransactions());
            }
          },
          builder: (context, state) {
            if (state is TransactionLoading) {
              return Center(child: CircularProgressIndicator(color: primaryPurple));
            }
            if (state is TransactionError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            List<TransactionItem> rawList = [];
            if (state is TransactionLoaded) {
              rawList = List.from(state.transactions);
            }

            if (_selectedFilter != 'All') {
              rawList = rawList.where((tx) => tx.type.toLowerCase() == _selectedFilter.toLowerCase()).toList();
            }

            if (_selectedFilterCategories.isNotEmpty) {
              final categoryState = context.read<CategoryBloc>().state;
              if (categoryState is CategoryLoaded) {
                rawList = rawList.where((tx) {
                  final cat = categoryState.categories.firstWhere((c) => c.id == tx.categoryId, orElse: () => CategoryItem(id: '', name: '', icon: Icons.help, color: Colors.grey, type: ''));
                  return _selectedFilterCategories.contains(cat.name);
                }).toList();
              }
            }

            if (_calendarFilterType == 'date') {
              rawList = rawList.where((tx) => tx.createdAt.year == _selectedYear && tx.createdAt.month == _selectedMonth).toList();
            } else if (_calendarFilterType == 'period' && _startDate != null && _endDate != null) {
              DateTime startClean = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
              DateTime endClean = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
              rawList = rawList.where((tx) => tx.createdAt.isAfter(startClean) && tx.createdAt.isBefore(endClean)).toList();
            }

            rawList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            Map<String, List<TransactionItem>> groupedTransactions = {};
            for (var tx in rawList) {
              String monthKey = DateFormat('MMMM - yyyy').format(tx.createdAt);
              if (groupedTransactions[monthKey] == null) {
                groupedTransactions[monthKey] = [];
              }
              groupedTransactions[monthKey]!.add(tx);
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildTopHeader(),
                    const SizedBox(height: 16),
                    _buildFilterRow(),
                    const SizedBox(height: 12),

                    if (_selectedFilterCategories.isNotEmpty || _calendarFilterType != 'none')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (_calendarFilterType == 'date')
                                  Chip(label: Text(DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth)), style: const TextStyle(color: Colors.white, fontSize: 11)), backgroundColor: primaryPurple),
                                if (_calendarFilterType == 'period' && _startDate != null && _endDate != null)
                                  Chip(label: Text("${DateFormat('dd/MM').format(_startDate!)} - ${DateFormat('dd/MM').format(_endDate!)}", style: const TextStyle(color: Colors.white, fontSize: 11)), backgroundColor: primaryPurple),
                                ..._selectedFilterCategories.map((catName) => Chip(
                                  label: Text(catName, style: const TextStyle(color: Colors.white, fontSize: 11)),
                                  backgroundColor: primaryPurple,
                                  onDeleted: () => setState(() => _selectedFilterCategories.remove(catName)),
                                )),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() {
                              _selectedFilterCategories.clear();
                              _calendarFilterType = 'none';
                              _startDate = null;
                              _endDate = null;
                            }),
                            child: Text("Clear Filter", style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),

                    const SizedBox(height: 8),

                    groupedTransactions.isEmpty 
                        ? (state is TransactionLoaded 
                            ? Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 32),
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                                child: const Center(child: Text("No transactions found", style: TextStyle(color: Colors.grey, fontSize: 15))),
                              )
                            : Center(child: CircularProgressIndicator(color: primaryPurple)))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: groupedTransactions.keys.length,
                            itemBuilder: (context, groupIndex) {
                              String monthHeader = groupedTransactions.keys.elementAt(groupIndex);
                              List<TransactionItem> txList = groupedTransactions[monthHeader]!;
                              
                              double monthIncome = 0;
                              double monthExpense = 0;
                              for (var item in txList) {
                                if (item.type == 'income') monthIncome += item.amount;
                                if (item.type == 'expense') monthExpense += item.amount;
                              }
                              return _buildMonthCardGroup(monthHeader, txList, monthIncome, monthExpense);
                            },
                          ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMonthCardGroup(String headerTitle, List<TransactionItem> items, double income, double expense) {
    final formatter = NumberFormat('#,##0');
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(headerTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Income", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)), const SizedBox(height: 4), Text(formatter.format(income), style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold))]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text("Expense", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)), const SizedBox(height: 4), Text(formatter.format(expense), style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold))]),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF3F4F6)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(color: Color(0xFFF3F4F6), height: 24),
            itemBuilder: (context, idx) {
              final tx = items[idx];
              final isExpense = tx.type == 'expense';
              String finalCategoryName = "Unknown";
              IconData finalIcon = Icons.local_offer_outlined;
              Color finalColor = Colors.indigo;

              final categoryState = context.read<CategoryBloc>().state;
              if (categoryState is CategoryLoaded) {
                final matchedCategory = categoryState.categories.firstWhere((cat) => cat.id == tx.categoryId, orElse: () => categoryState.categories.first);
                finalCategoryName = matchedCategory.name;
                finalIcon = matchedCategory.icon;
                finalColor = matchedCategory.color;
              }
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionDetailScreen(
                        transaction: tx,
                        categoryName: finalCategoryName,
                        categoryIcon: finalIcon,
                        categoryColor: finalColor
                      )
                    )
                  );
                  if (context.mounted) {
                    BlocProvider.of<TransactionBloc>(context).add(LoadTransactions());
                  }
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: finalColor,
                      child: Icon(finalIcon, color: Colors.white, size: 22)
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(finalCategoryName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 2),
                          if (tx.note.isNotEmpty && tx.note != "No note") Text(tx.note, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 13, fontStyle: FontStyle.italic)),
                          const SizedBox(height: 2),
                          Text(DateFormat('dd/MM HH:mm').format(tx.createdAt.toLocal()), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(isExpense ? "-${formatter.format(tx.amount)}" : "+${formatter.format(tx.amount)}", style: TextStyle(color: isExpense ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(color: isExpense ? const Color(0xFFFFE4E6) : const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(isExpense ? Icons.arrow_downward : Icons.arrow_upward, size: 10, color: isExpense ? Colors.red : Colors.green),
                              const SizedBox(width: 2),
                              Text(tx.type, style: TextStyle(color: isExpense ? Colors.red : Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () { if (widget.onTabChanged != null) widget.onTabChanged!(0); },
          child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black))
        ),
        const Text("Transaction History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(width: 36),
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
                      decoration: BoxDecoration(color: isSelected ? primaryPurple : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                      child: Text(tab, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.grey)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(onTap: () => _showFilterBottomSheet(context), child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _selectedFilterCategories.isNotEmpty ? primaryPurple : Colors.white, borderRadius: BorderRadius.circular(12)), child: Icon(Icons.filter_alt_outlined, color: _selectedFilterCategories.isNotEmpty ? Colors.white : Colors.black54, size: 20))),
        const SizedBox(width: 8),
        GestureDetector(onTap: _showCalendarFilterDialog, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _calendarFilterType != 'none' ? primaryPurple : Colors.white, borderRadius: BorderRadius.circular(12)), child: Icon(Icons.calendar_month_outlined, color: _calendarFilterType != 'none' ? Colors.white : Colors.black54, size: 20))),
      ],
    );
  }
}