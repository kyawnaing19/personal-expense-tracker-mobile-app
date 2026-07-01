// // import 'package:expense_tracker/features/auth/presentation/bloc/category_bloc.dart';
// // import 'package:expense_tracker/features/auth/presentation/bloc/category_event.dart';
// // import 'package:expense_tracker/features/auth/presentation/bloc/category_state.dart';
// // import 'package:expense_tracker/features/auth/presentation/bloc/transaction_bloc.dart';
// // import 'package:expense_tracker/features/auth/presentation/bloc/transaction_event.dart';
// // import 'package:expense_tracker/models/category_model.dart';
// // import 'package:expense_tracker/models/record_model.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:intl/intl.dart';
// // import 'package:image_picker/image_picker.dart';

// // List<RecordItem> globalRecords = [];
// // enum CategoryState { view, calculator, deleteConfirm, add, edit, calendar }

// // class CategoryScreen extends StatefulWidget {
// //   final VoidCallback? onBackToHome; 

// //   const CategoryScreen({Key? key, this.onBackToHome}) : super(key: key);

// //   @override
// //   State<CategoryScreen> createState() => _CategoryScreenState();
// // }
// // class _CategoryScreenState extends State<CategoryScreen> with SingleTickerProviderStateMixin {
// //   CategoryState _currentState = CategoryState.view;
// //   int _currentTabIndex = 2;
  
// //   late TabController _tabController;

// //   // 🧮 Calculator State Variables
// //   String _amount = "0";             
// //   String _expression = "";          
// //   double? _firstOperand;            
// //   String? _currentOperator;         
// //   bool _shouldResetDisplay = false; 

// //   final List<Color> _availableColors = [
// //     const Color(0xFF6366F1), const Color(0xFF10B981), const Color(0xFFF59E0B),
// //     const Color(0xFFEF4444), const Color(0xFFEC4899), const Color(0xFF06B6D4),
// //     const Color(0xFF8B5CF6), const Color(0xFF14B8A6), const Color(0xFFF43F5E),
// //     const Color(0xFF84CC16), const Color(0xFF3B82F6), const Color(0xFFEAB308),
// //     const Color(0xFF6B7280), const Color(0xFF9A3412), const Color.fromARGB(255, 233, 243, 90),
// //   ];

// //   final List<IconData> _availableIcons = [
// //     Icons.restaurant, Icons.shopping_bag, Icons.directions_car, Icons.home,
// //     Icons.local_hospital, Icons.school, Icons.flight, Icons.movie,
// //     Icons.fitness_center, Icons.dry_cleaning, Icons.pets, Icons.wifi,
// //     Icons.build, Icons.card_giftcard, Icons.attach_money, Icons.payments,
// //     Icons.trending_up, Icons.storefront, Icons.account_balance, Icons.calendar_month_outlined,    
// //     Icons.handshake, Icons.phone, Icons.school_outlined, Icons.music_note_outlined,
// //     Icons.headphones, Icons.local_cafe, Icons.health_and_safety, Icons.computer,
// //   ];

// //   CategoryItem? _selectedCategory;
// //   CategoryItem? _itemToModify;
  
// //   final TextEditingController _nameController = TextEditingController();
// //   final TextEditingController _noteController = TextEditingController();
  
// //   Color _tempColor = const Color(0xFFF59E0B);
// //   IconData _tempIcon = Icons.restaurant;
// //   String _tempType = "Expense"; 
  
// //   XFile? _pickedImage;
// //   String _calendarHeaderText = "";
// //   DateTime _currentSelectedCalendarDate = DateTime.now();

// //   @override
// //   void initState() {
// //     super.initState();
// //     _calendarHeaderText = DateFormat('EEE, MMM d, yyyy').format(DateTime.now());
// //     _tabController = TabController(length: 2, vsync: this);
    
// //     _tabController.addListener(() {
// //       if (!_tabController.indexIsChanging) {
// //         setState(() {});
// //       }
// //     });
    
// //     BlocProvider.of<CategoryBloc>(context).add(LoadCategories());
// //   }

// //   @override
// //   void dispose() {
// //     _nameController.dispose();
// //     _noteController.dispose();
// //     _tabController.dispose();
// //     super.dispose();
// //   }

// //   Future<void> _showImageSourceDialog() async {
// //     showDialog(
// //       context: context,
// //       builder: (BuildContext context) {
// //         return AlertDialog(
// //           title: const Text("Choose Image Source", style: TextStyle(fontWeight: FontWeight.bold)),
// //           content: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               ListTile(
// //                 leading: const Icon(Icons.camera_alt, color: Colors.blue),
// //                 title: const Text("Take a Photo (Camera)"),
// //                 onTap: () async {
// //                   Navigator.pop(context);
// //                   final ImagePicker picker = ImagePicker();
// //                   final XFile? image = await picker.pickImage(source: ImageSource.camera);
// //                   if (image != null) setState(() => _pickedImage = image);
// //                 },
// //               ),
// //               ListTile(
// //                 leading: const Icon(Icons.photo_library, color: Colors.green),
// //                 title: const Text("Choose from Gallery"),
// //                 onTap: () async {
// //                   Navigator.pop(context);
// //                   final ImagePicker picker = ImagePicker();
// //                   final XFile? image = await picker.pickImage(source: ImageSource.gallery);
// //                   if (image != null) setState(() => _pickedImage = image);
// //                 },
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   void _onKeypadPressed(String value) {
// //     setState(() {
// //       if (value == "Today") {
// //         _currentSelectedCalendarDate = DateTime.now();
// //         _calendarHeaderText = DateFormat('EEE, MMM d, yyyy').format(_currentSelectedCalendarDate);
// //         _currentState = CategoryState.calendar; 
// //         return;
// //       }

// //       if (value == "⌫") {
// //         if (_amount != "0" && _amount != "Error") {
// //           if (_amount.length > 1) {
// //             _amount = _amount.substring(0, _amount.length - 1);
// //           } else {
// //             _amount = "0";
// //           }
// //         }
// //         return;
// //       }

// //       if (value == "+" || value == "-" || value == "×" || value == "÷") {
// //         if (_amount == "Error") return;
// //         _firstOperand = double.tryParse(_amount);
// //         _currentOperator = value;
// //         _expression = "${_amount} ${_currentOperator}"; 
// //         _shouldResetDisplay = true; 
// //         return;
// //       }

// //       if (value == "=") {
// //         _calculateResult();
// //         return;
// //       }

// //       if (value == "✓") {
// //         double parsedAmount = double.tryParse(_amount) ?? 0.0;
        
// //         if (parsedAmount == 0.0 || _amount == "0" || _amount == "Error") {
// //           return; 
// //         }

// //         if (_selectedCategory != null) {
// //           String userNote = _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : "No note";
          
// //           BlocProvider.of<TransactionBloc>(context).add(
// //             AddTransactionRequested(
// //               categoryId: _selectedCategory!.id,
// //               amount: parsedAmount,
// //               note: userNote,
// //             ),
// //           );

// //           BlocProvider.of<TransactionBloc>(context).add(LoadTransactions());
// //           BlocProvider.of<CategoryBloc>(context).add(LoadCategories()); 
// //         }
        
// //         _amount = "0";
// //         _expression = "";
// //         _firstOperand = null;
// //         _currentOperator = null;
// //         _shouldResetDisplay = false;
// //         _noteController.clear();
// //         _pickedImage = null;
// //         _selectedCategory = null;
// //         _currentState = CategoryState.view;
// //         return;
// //       }

// //       if (value == ".") {
// //         if (_shouldResetDisplay || _amount == "Error") {
// //           _amount = "0.";
// //           _shouldResetDisplay = false;
// //         } else if (!_amount.contains(".")) {
// //           _amount += ".";
// //         }
// //         return;
// //       }

// //       if (_shouldResetDisplay || _amount == "Error") {
// //         _amount = value;
// //         _shouldResetDisplay = false;
// //       } else {
// //         if (_amount == "0") {
// //           _amount = value; 
// //         } else {
// //           _amount += value; 
// //         }
// //       }
// //     });
// //   }

// //   void _calculateResult() {
// //     if (_firstOperand == null || _currentOperator == null) return;
    
// //     double secondOperand = double.tryParse(_amount) ?? 0;
// //     double result = 0;

// //     switch (_currentOperator) {
// //       case "+": result = _firstOperand! + secondOperand; break;
// //       case "-": result = _firstOperand! - secondOperand; break;
// //       case "×": result = _firstOperand! * secondOperand; break;
// //       case "÷":
// //         if (secondOperand != 0) {
// //           result = _firstOperand! / secondOperand;
// //         } else {
// //           _amount = "Error"; _expression = ""; _firstOperand = null; _currentOperator = null;
// //           return;
// //         }
// //         break;
// //     }

// //     if (result % 1 == 0) {
// //       _amount = result.toInt().toString();
// //     } else {
// //       _amount = result.toStringAsFixed(2); 
// //     }
    
// //     _firstOperand = null;
// //     _currentOperator = null;
// //     _expression = ""; 
// //   }

// //   void _showActionBottomSheet(CategoryItem item) {
// //     showModalBottomSheet(
// //       context: context,
// //       backgroundColor: Colors.transparent,
// //       builder: (context) => Container(
// //         padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
// //         decoration: const BoxDecoration(
// //           color: Color(0xFFF7F5FC),
// //           borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
// //         ),
// //         child: SafeArea(
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               ListTile(
// //                 leading: const Icon(Icons.edit_outlined, color: Color(0xFF6366F1)),
// //                 title: const Text('Edit Category', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1F2937))),
// //                 onTap: () {
// //                   Navigator.pop(context);
// //                   setState(() {
// //                     _itemToModify = item;
// //                     _nameController.text = item.name;
// //                     _tempColor = item.color;
// //                     _tempIcon = item.icon;
// //                     _tempType = item.type == 'expense' ? "Expense" : "Income";
// //                     _currentState = CategoryState.edit;
// //                   });
// //                 },
// //               ),
// //               const Divider(color: Colors.black12, height: 1),
// //               ListTile(
// //                 leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
// //                 title: const Text('Delete Category', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1F2937))),
// //                 onTap: () {
// //                   Navigator.pop(context);
// //                   setState(() {
// //                     _itemToModify = item;
// //                     _currentState = CategoryState.deleteConfirm;
// //                   });
// //                 },
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final double screenWidth = MediaQuery.of(context).size.width;
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFE8DEF8),
// //       resizeToAvoidBottomInset: true,
// //       body: SafeArea(
// //         child: LayoutBuilder(
// //           builder: (context, constraints) {
// //             return Column(
// //               children: [
// //                 _buildAppBar(), 
// //                 Expanded(
// //                   child: Stack(
// //                     children: [
// //                       if (_currentState == CategoryState.view || 
// //                           _currentState == CategoryState.calculator || 
// //                           _currentState == CategoryState.deleteConfirm)
// //                         Column(
// //                           children: [

// // Padding(
// //   padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
// //   child: Container(
// //     height: 40,
// //     decoration: BoxDecoration(
// //       color: Colors.white,
// //       borderRadius: BorderRadius.circular(12),
// //     ),
// //     child: TabBar(
// //       controller: _tabController,
// //       labelColor: Colors.white, 
// //       unselectedLabelColor: Colors.grey[600], 
// //       indicatorSize: TabBarIndicatorSize.tab,
// //          indicator: BoxDecoration(
// //         borderRadius: BorderRadius.circular(12),
// //         color: const Color(0xFF7F3DFF),
// //       ),
// //       tabs: const [
// //         Tab(
// //           child: Center(
// //             child: Text("Expense", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
// //           ),
// //         ),
// //         Tab(
// //           child: Center(
// //             child: Text("Income", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
// //           ),
// //         ),
// //       ],
// //     ),
// //   ),
// // ),
// //                             Expanded(
// //                               child: TabBarView(
// //                                 controller: _tabController,
// //                                 physics: const NeverScrollableScrollPhysics(), // ⚡ လေးမနေစေရန် Swipe Physics ကို ပိတ်ထားပါတယ်
// //                                 children: [
// //                                   _buildCategoryListFiltered(type: 'expense'),
// //                                   _buildCategoryListFiltered(type: 'income'),
// //                                 ],
// //                               ),
// //                             ),
// //                           ],
// //                         ),

// //                       if (_currentState == CategoryState.calculator) _buildCalculatorSection(screenWidth),
// //                       if (_currentState == CategoryState.deleteConfirm) _buildDeleteAlertBox(screenWidth),
// //                       if (_currentState == CategoryState.add) _buildAddCategoryView(constraints),
// //                       if (_currentState == CategoryState.edit) _buildEditCategoryView(constraints),
// //                       if (_currentState == CategoryState.calendar) _buildCalendarView(screenWidth),
// //                     ],
// //                   ),
// //                 ),
                
// //               ],
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildAppBar() {
// //   String title = "Categories";
// //   if (_currentState == CategoryState.add) title = "Add New Category";
// //   if (_currentState == CategoryState.edit) title = "Edit Category";

// //   return Padding(
// //     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
// //     child: Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         GestureDetector(
// //           onTap: () {
// //             if (_currentState == CategoryState.view) {
// //               // ⚡ Navigator.pop အစား အောက်က callback အသစ်ကို သုံးပေးရပါမယ်
// //               if (widget.onBackToHome != null) {
// //                 widget.onBackToHome!(); 
// //               }
// //             } else if (_currentState == CategoryState.calendar) {
// //               setState(() => _currentState = CategoryState.calculator);
// //             } else {
// //               setState(() => _currentState = CategoryState.view);
// //             }
// //           },
// //           child: Container(
// //             padding: const EdgeInsets.all(8),
// //             decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
// //             child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF1F2937)),
// //           ),
// //         ),
// //         Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
// //         GestureDetector(
// //           onTap: () => setState(() {
// //             _selectedCategory = null; 
// //             _currentState = CategoryState.view;
// //           }),
// //           child: Container(
// //             padding: const EdgeInsets.all(8),
// //             decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
// //             child: const Icon(Icons.close, size: 16, color: Color(0xFF1F2937)),
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// // }

// //   Widget _buildCategoryListFiltered({required String type}) {
// //     return BlocConsumer<CategoryBloc, CategoryStateBase>(
// //       listener: (context, state) {
// //         if (state is CategoryError) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(content: Text(state.message), backgroundColor: Colors.black),
// //           );
// //         }
// //       },
// //       builder: (context, state) {
// //         if (state is CategoryLoading) {
// //           return const Center(child: CircularProgressIndicator(color: Color(0xFF7F3DFF)));
// //         }

// //         List<CategoryItem> currentCategories = [];
// //         if (state is CategoryLoaded) {
// //           currentCategories = state.categories.where((c) => c.type == type).toList();
// //         }

// //         return ListView.builder(
// //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //           itemCount: currentCategories.length + 1,
// //           itemBuilder: (context, index) {
// //             if (index == currentCategories.length) {
// //               return Container(
// //                 margin: const EdgeInsets.only(bottom: 12),
// //                 decoration: BoxDecoration(
// //                   color: const Color(0xFFF9F8FD),
// //                   borderRadius: BorderRadius.circular(16),
// //                 ),
// //                 child: ListTile(
// //                   contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
// //                   leading: const Icon(Icons.add, color: Colors.black, size: 24),
// //                   title: const Text("Add New Category", 
// //                       style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15)),
// //                   onTap: () => setState(() {
// //                     _nameController.clear();
// //                     _tempColor = const Color(0xFFF59E0B);
// //                     _tempIcon = Icons.restaurant;
// //                     _tempType = type == 'expense' ? "Expense" : "Income"; 
// //                     _currentState = CategoryState.add;
// //                   }),
// //                 ),
// //               );
// //             }

// //             final item = currentCategories[index];
// //             return Container(
// //               margin: const EdgeInsets.only(bottom: 12),
// //               decoration: BoxDecoration(
// //                 color: const Color(0xFFF9F8FD),
// //                 borderRadius: BorderRadius.circular(16),
// //               ),
// //               child: ListTile(
// //                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
// //                 onTap: () => setState(() {
// //                   _selectedCategory = item;
// //                   _amount = "0"; _expression = ""; _firstOperand = null; _currentOperator = null; _shouldResetDisplay = false;
// //                   _currentState = CategoryState.calculator;
// //                 }),
// //                 leading: CircleAvatar(
// //                   radius: 22,
// //                   backgroundColor: item.color,
// //                   child: Icon(item.icon, color: Colors.white, size: 22),
// //                 ),
// //                 title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 15)),
// //                 trailing: IconButton(
// //                   icon: const Icon(Icons.more_vert, size: 22, color: Colors.grey),
// //                   onPressed: () => _showActionBottomSheet(item),
// //                 ),
// //               ),
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildCalculatorSection(double screenWidth) {
// //     return Align(
// //       alignment: Alignment.bottomCenter,
// //       child: Container(
// //         color: const Color(0xFFF7F5FC),
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           crossAxisAlignment: CrossAxisAlignment.end,
// //           children: [
// //             if (_expression.isNotEmpty)
// //               Padding(
// //                 padding: const EdgeInsets.only(bottom: 4.0),
// //                 child: Text(_expression, style: const TextStyle(fontSize: 14, color: Colors.black54)),
// //               ),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 const Icon(Icons.article_outlined, color: Color(0xFF49454F), size: 28),
// //                 Text(_amount, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1D1B20))),
// //               ],
// //             ),
// //             const SizedBox(height: 12),
// //             TextField(
// //               controller: _noteController,
// //               decoration: InputDecoration(
// //                 hintText: "Note: Enter a note ......",
// //                 hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
// //                 filled: true,
// //                 fillColor: const Color(0xFFF7F5FC),
// //                 suffixIcon: IconButton(
// //                   icon: Icon(_pickedImage != null ? Icons.check_circle : Icons.camera_alt_outlined, 
// //                              color: _pickedImage != null ? Colors.green : Colors.grey[600]),
// //                   onPressed: _showImageSourceDialog,
// //                 ), 
// //                 enabledBorder: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(4),
// //                   borderSide: const BorderSide(color: Color(0xFFCEBEE7), width: 1.5),
// //                 ),
// //                 focusedBorder: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(4),
// //                   borderSide: const BorderSide(color: Color(0xFF7F3DFF), width: 2),
// //                 ),
// //                 contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// //               ),
// //             ),
// //             const SizedBox(height: 12),
// //             _buildBalancedKeypadUI(), 
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildBalancedKeypadUI() {
// //     return LayoutBuilder(
// //       builder: (context, constraints) {
// //         double cellHeight = 44; 

// //         return GridView.count(
// //           shrinkWrap: true,
// //           physics: const NeverScrollableScrollPhysics(),
// //           crossAxisCount: 4,
// //           mainAxisSpacing: 8,
// //           crossAxisSpacing: 10,
// //           childAspectRatio: (constraints.maxWidth / 4) / cellHeight,
// //           children: [
// //             _buildBaseButton("7"), _buildBaseButton("8"), _buildBaseButton("9"), _buildActionButton("Today"),
// //             _buildBaseButton("4"), _buildBaseButton("5"), _buildBaseButton("6"), _buildActionButton("+"),
// //             _buildBaseButton("1"), _buildBaseButton("2"), _buildBaseButton("3"), _buildActionButton("-"),
// //             _buildBaseButton("."), _buildBaseButton("0"), _buildActionButton("⌫"), _buildActionButton("✓"),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildBaseButton(String label) {
// //     return GestureDetector(
// //       onTap: () => _onKeypadPressed(label),
// //       child: Container(
// //         decoration: BoxDecoration(
// //           color: const Color(0xFFEFE7F4), 
// //           borderRadius: BorderRadius.circular(6),
// //         ),
// //         child: Center(
// //           child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildActionButton(String label) {
// //     bool isConfirm = label == "✓";
// //     bool isToday = label == "Today";
// //     Color btnColor = const Color(0xFFEFE7F4);
// //     Color textColor = Colors.black;

// //     if (isConfirm) {
// //       btnColor = const Color(0xFFEFE7F4);
// //     } else if (isToday) {
// //       textColor = Colors.grey[600]!;
// //     }

// //     return GestureDetector(
// //       onTap: () => _onKeypadPressed(label),
// //       child: Container(
// //         decoration: BoxDecoration(
// //           color: btnColor,
// //           borderRadius: BorderRadius.circular(6),
// //         ),
// //         child: Center(
// //           child: isConfirm 
// //             ? const Icon(Icons.check, color: Colors.black, size: 22)
// //             : Text(label, style: TextStyle(fontSize: isToday ? 13 : 18, fontWeight: FontWeight.w600, color: textColor)),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildDeleteAlertBox(double screenWidth) {
// //     return Container(
// //       color: Colors.black26,
// //       alignment: Alignment.center,
// //       child: Container(
// //         width: screenWidth * 0.82,
// //         padding: const EdgeInsets.all(24),
// //         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             const Text(
// //               "Are you sure you want to delete?",
// //               textAlign: TextAlign.center,
// //               style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
// //             ),
// //             const SizedBox(height: 24),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //               children: [
// //                 TextButton(
// //                   onPressed: () => setState(() => _currentState = CategoryState.view),
// //                   child: const Text("Cancel", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
// //                 ),
// //                 TextButton(
// //                   onPressed: () {
// //                     if (_itemToModify != null) {
// //                       BlocProvider.of<CategoryBloc>(context).add(DeleteCategoryRequested(_itemToModify!.id));
// //                       BlocProvider.of<TransactionBloc>(context).add(LoadTransactions());
// //                       _selectedCategory = null;
// //                       _itemToModify = null;
// //                       setState(() => _currentState = CategoryState.view);
// //                     }
// //                   },
// //                   child: const Text("Confirm", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
// //                 ),
// //               ],
// //             )
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //  Widget _buildAddCategoryView(BoxConstraints constraints) {
// //   return SingleChildScrollView(
// //     physics: const BouncingScrollPhysics(),
// //     child: Padding(
// //       padding: const EdgeInsets.all(16.0),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           _buildFormInputs(isDisableType: true), 
// //           const SizedBox(height: 16),
// //           const Text("Choose Colour", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
// //           const SizedBox(height: 12),
// //           _buildColorPicker(),
// //           const SizedBox(height: 20),
// //           const Text("Choose Icon", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
// //           const SizedBox(height: 12),
          
// //           // 🎯 [FIXED] Expanded ကို ဖြုတ်လိုက်ပြီး တိုက်ရိုက်ခေါ်သုံးရပါမည်။
// //           _buildIconGrid(constraints),
          
// //           const SizedBox(height: 20), // ခလုတ်နဲ့ အကွာအဝေးလေး နည်းနည်းခြားရန်
          
// //           _buildSaveButton(
// //             label: "+ Add New Category",
// //             onPressed: () {
// //               if (_nameController.text.isNotEmpty) {
// //                 BlocProvider.of<CategoryBloc>(context).add(
// //                   AddCategoryRequested(
// //                     name: _nameController.text.trim(),
// //                     icon: _tempIcon,
// //                     color: _tempColor,
// //                     type: _tempType.toLowerCase(),
// //                   ),
// //                 );
// //                 setState(() => _currentState = CategoryState.view);
// //               }
// //             },
// //           ),
// //         ],
// //       ),
// //     ),
// //   );
// // }
// //   Widget _buildEditCategoryView(BoxConstraints constraints) {
// //     return Container(
// //       color: Colors.white,
// //       padding: const EdgeInsets.all(16.0),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           _buildFormInputs(isDisableType: true), 
// //           const SizedBox(height: 16),
// //           const Text("Choose Colour", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
// //           const SizedBox(height: 12),
// //           _buildColorPicker(),
// //           const Spacer(),
// //           Row(
// //             children: [
// //               Expanded(
// //                 child: SizedBox(
// //                   height: 48,
// //                   child: OutlinedButton(
// //                     style: OutlinedButton.styleFrom(
// //                       side: const BorderSide(color: Color(0xFF7F3DFF), width: 1.5),
// //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //                     ),
// //                     onPressed: () => setState(() => _currentState = CategoryState.view),
// //                     child: const Text("Cancel", style: TextStyle(color: Color(0xFF7F3DFF), fontSize: 16, fontWeight: FontWeight.bold)),
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(width: 16),
// //               Expanded(
// //                 child: _buildSaveButton(
// //                   label: "Done",
// //                   onPressed: () {
// //                     if (_nameController.text.isNotEmpty && _itemToModify != null) {
// //                       BlocProvider.of<CategoryBloc>(context).add(
// //                         UpdateCategoryRequested(
// //                           id: _itemToModify!.id,
// //                           name: _nameController.text.trim(),
// //                           icon: _tempIcon,
// //                           color: _tempColor,
// //                           type: _tempType.toLowerCase(),
// //                         ),
// //                       );
// //                       _nameController.clear();
// //                       _itemToModify = null;
// //                       setState(() => _currentState = CategoryState.view);
// //                     }
// //                   },
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildCalendarView(double screenWidth) {
// //     final List<String> weekdays = ["S", "M", "T", "W", "T", "F", "S"];
// //     final List<String> days = [
// //       "31", "1", "2", "3", "4", "5", "6",
// //       "7", "8", "9", "10", "11", "12", "13",
// //       "14", "15", "16", "17", "18", "19", "20",
// //       "21", "22", "23", "24", "25", "26", "27",
// //       "28", "29", "30", "1", "2", "3", "4"
// //     ];
// //     return Container(
// //       color: Colors.white,
// //       padding: const EdgeInsets.symmetric(horizontal: 16),
// //       child: Column(
// //         children: [
// //           const SizedBox(height: 10),
// //           Text(_calendarHeaderText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
// //           const SizedBox(height: 30),
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceAround,
// //             children: weekdays.map((w) => SizedBox(
// //               width: screenWidth / 8,
// //               child: Text(w, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
// //             )).toList(),
// //           ),
// //           const SizedBox(height: 16),
// //           Expanded(
// //             child: GridView.builder(
// //               itemCount: days.length,
// //               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //                 crossAxisCount: 7, mainAxisSpacing: 18, crossAxisSpacing: 10,
// //               ),
// //               itemBuilder: (context, index) {
// //                 String day = days[index];
// //                 bool isCurrentMonth = !(index == 0 || index > 30);
// //                 bool isSelectedDay = isCurrentMonth && (int.tryParse(day) == _currentSelectedCalendarDate.day);
// //                 return GestureDetector(
// //                   onTap: () {
// //                     if (isCurrentMonth) {
// //                       setState(() {
// //                         int selectedDayInt = int.parse(day);
// //                         _currentSelectedCalendarDate = DateTime(DateTime.now().year, DateTime.now().month, selectedDayInt);
// //                         _calendarHeaderText = DateFormat('EEE, MMM d, yyyy').format(_currentSelectedCalendarDate);
// //                       });
// //                     }
// //                   },
// //                   child: Container(
// //                     decoration: BoxDecoration(
// //                       color: isSelectedDay ? const Color(0xFF38BDF8) : Colors.transparent,
// //                       shape: BoxShape.circle,
// //                     ),
// //                     alignment: Alignment.center,
// //                     child: Text(
// //                       day,
// //                       style: TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: isSelectedDay ? FontWeight.bold : FontWeight.w500,
// //                         color: isSelectedDay ? Colors.white : (isCurrentMonth ? Colors.black : Colors.grey[400]),
// //                       ),
// //                     ),
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //           Padding(
// //             padding: const EdgeInsets.only(bottom: 20.0),
// //             child: _buildSaveButton(
// //               label: "Done", 
// //               onPressed: () => setState(() => _currentState = CategoryState.calculator),
// //             ),
// //           )
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildFormInputs({bool isDisableType = false}) {
// //     return Column(
// //       children: [
// //         ListTile(
// //           contentPadding: EdgeInsets.zero,
// //           title: const Text("Icon", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
// //           trailing: Stack(
// //             alignment: Alignment.bottomRight,
// //             children: [
// //               CircleAvatar(backgroundColor: _tempColor, radius: 24, child: Icon(_tempIcon, color: Colors.white, size: 24)),
// //               Container(
// //                 padding: const EdgeInsets.all(2),
// //                 decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
// //                 child: const Icon(Icons.edit, size: 10, color: Colors.black),
// //               )
// //             ],
// //           ),
// //         ),
// //         const SizedBox(height: 10),
// //         ListTile(
// //           contentPadding: EdgeInsets.zero,
// //           title: const Text("Name", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
// //           trailing: SizedBox(
// //             width: 180,
// //             child: TextField(
// //               controller: _nameController,
// //               textAlign: TextAlign.end,
// //               style: const TextStyle(fontSize: 15, color: Colors.black),
// //               decoration: const InputDecoration(
// //                 hintText: "Enter category name...",
// //                 border: InputBorder.none,
// //                 suffixIcon: Icon(Icons.edit, size: 16, color: Colors.grey),
// //               ),
// //             ),
// //           ),
// //         ),
// //         const SizedBox(height: 10),
// //         ListTile(
// //           contentPadding: EdgeInsets.zero,
// //           title: const Text("Type", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
// //           trailing: Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 12.0),
// //             child: Text(_tempType, style: const TextStyle(color: Colors.black, fontSize: 16)),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildColorPicker() {
// //     return SizedBox(
// //       height: 46,
// //       child: ListView.builder(
// //         scrollDirection: Axis.horizontal,
// //         itemCount: _availableColors.length,
// //         itemBuilder: (context, index) {
// //           final color = _availableColors[index];
// //           bool isSelected = _tempColor == color;
// //           return GestureDetector(
// //             onTap: () => setState(() => _tempColor = color),
// //             child: Container(
// //               margin: const EdgeInsets.symmetric(horizontal: 6),
// //               width: 40,
// //               decoration: BoxDecoration(
// //                 color: color,
// //                 shape: BoxShape.circle,
// //                 border: isSelected ? Border.all(color: const Color(0xFFFF69B4), width: 3) : null,
// //               ),
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   Widget _buildIconGrid(BoxConstraints constraints) {
// //     return GridView.builder(
// //       shrinkWrap: true,
// //       physics: const NeverScrollableScrollPhysics(),
// //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //         crossAxisCount: 5, mainAxisSpacing: 16, crossAxisSpacing: 16
// //       ),
// //       itemCount: _availableIcons.length,
// //       itemBuilder: (context, index) {
// //         final icon = _availableIcons[index];
// //         bool isSelected = _tempIcon == icon;
// //         return GestureDetector(
// //           onTap: () => setState(() => _tempIcon = icon),
// //           child: CircleAvatar(
// //             backgroundColor: isSelected ? const Color(0xFFFFD1EC) : const Color(0xFFEFEFEF),
// //             child: Icon(icon, color: isSelected ? const Color(0xFFFF69B4) : Colors.grey[500]),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildSaveButton({required String label, required VoidCallback onPressed}) {
// //     return SizedBox(
// //       width: double.infinity,
// //       height: 48,
// //       child: ElevatedButton(
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: const Color(0xFF7F3DFF),
// //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //           elevation: 0,
// //         ),
// //         onPressed: onPressed,
// //         child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
// //       ),
// //     );
// //   }
// // }


// // import 'package:expense_tracker/features/auth/presentation/bloc/category_bloc.dart';
// // import 'package:expense_tracker/features/auth/presentation/bloc/category_event.dart';
// // import 'package:expense_tracker/features/auth/presentation/bloc/category_state.dart';
// // import 'package:expense_tracker/features/auth/presentation/bloc/transaction_bloc.dart';
// // import 'package:expense_tracker/features/auth/presentation/bloc/transaction_event.dart';
// // import 'package:expense_tracker/models/category_model.dart';
// // import 'package:expense_tracker/models/record_model.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:intl/intl.dart';
// // import 'package:image_picker/image_picker.dart';

// // List<RecordItem> globalRecords = [];
// // enum CategoryState { view, calculator, deleteConfirm, add, edit, calendar }

// // class CategoryScreen extends StatefulWidget {
// //   final VoidCallback? onBackToHome; 

// //   const CategoryScreen({Key? key, this.onBackToHome}) : super(key: key);

// //   @override
// //   State<CategoryScreen> createState() => _CategoryScreenState();
// // }
// // class _CategoryScreenState extends State<CategoryScreen> with SingleTickerProviderStateMixin {
// //   CategoryState _currentState = CategoryState.view;
// //   int _currentTabIndex = 2;
  
// //   late TabController _tabController;

// //   String _amount = "0";             
// //   String _expression = "";          
// //   double? _firstOperand;            
// //   String? _currentOperator;         
// //   bool _shouldResetDisplay = false; 

// //   // Colors aligned with screenshots
// //   final List<Color> _availableColors = [
// //     const Color(0xFF6366F1), const Color(0xFF10B981), const Color(0xFFF59E0B),
// //     const Color(0xFFEF4444), const Color(0xFFEC4899), const Color(0xFF06B6D4),
// //     const Color(0xFF8B5CF6), const Color(0xFF14B8A6), const Color(0xFFF43F5E),
// //     const Color(0xFF84CC16), const Color(0xFF3B82F6), const Color(0xFFEAB308),
// //     const Color(0xFF6B7280), const Color(0xFF9A3412), const Color(0xFFF3ED5A),
// //   ];

// //   final List<IconData> _availableIcons = [
// //     Icons.restaurant, Icons.shopping_bag, Icons.directions_car, Icons.home,
// //     Icons.local_hospital, Icons.school, Icons.flight, Icons.movie,
// //     Icons.fitness_center, Icons.dry_cleaning, Icons.pets, Icons.wifi,
// //     Icons.build, Icons.card_giftcard, Icons.attach_money, Icons.payments,
// //     Icons.trending_up, Icons.storefront, Icons.account_balance, Icons.calendar_month_outlined,    
// //     Icons.handshake, Icons.phone, Icons.school_outlined, Icons.music_note_outlined,
// //     Icons.headphones, Icons.local_cafe, Icons.health_and_safety, Icons.computer,
// //   ];

// //   CategoryItem? _selectedCategory;
// //   CategoryItem? _itemToModify;
  
// //   final TextEditingController _nameController = TextEditingController();
// //   final TextEditingController _noteController = TextEditingController();
  
// //   Color _tempColor = const Color(0xFFF59E0B);
// //   IconData _tempIcon = Icons.restaurant;
// //   String _tempType = "Expense"; 
  
// //   XFile? _pickedImage;
// //   String _calendarHeaderText = "";
// //   DateTime _currentSelectedCalendarDate = DateTime.now();

// //   @override
// //   void initState() {
// //     super.initState();
// //     _calendarHeaderText = DateFormat('EEE, MMM d, yyyy').format(DateTime.now());
// //     _tabController = TabController(length: 2, vsync: this);
    
// //     _tabController.addListener(() {
// //       if (!_tabController.indexIsChanging) {
// //         setState(() {});
// //       }
// //     });
    
// //     BlocProvider.of<CategoryBloc>(context).add(LoadCategories());
// //   }

// //   @override
// //   void dispose() {
// //     _nameController.dispose();
// //     _noteController.dispose();
// //     _tabController.dispose();
// //     super.dispose();
// //   }

// //   Future<void> _showImageSourceDialog() async {
// //     showDialog(
// //       context: context,
// //       builder: (BuildContext context) {
// //         return AlertDialog(
// //           title: const Text("Choose Image Source", style: TextStyle(fontWeight: FontWeight.bold)),
// //           content: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               ListTile(
// //                 leading: const Icon(Icons.camera_alt, color: Color(0xFF6366F1)),
// //                 title: const Text("Take a Photo (Camera)"),
// //                 onTap: () async {
// //                   Navigator.pop(context);
// //                   final ImagePicker picker = ImagePicker();
// //                   final XFile? image = await picker.pickImage(source: ImageSource.camera);
// //                   if (image != null) setState(() => _pickedImage = image);
// //                 },
// //               ),
// //               ListTile(
// //                 leading: const Icon(Icons.photo_library, color: Color(0xFF10B981)),
// //                 title: const Text("Choose from Gallery"),
// //                 onTap: () async {
// //                   Navigator.pop(context);
// //                   final ImagePicker picker = ImagePicker();
// //                   final XFile? image = await picker.pickImage(source: ImageSource.gallery);
// //                   if (image != null) setState(() => _pickedImage = image);
// //                 },
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }
// //   void _onKeypadPressed(String value) {
// //     setState(() {
// //       if (value == "Today") {
// //         _currentSelectedCalendarDate = DateTime.now();
// //         _calendarHeaderText = DateFormat('EEE, MMM d, yyyy').format(_currentSelectedCalendarDate);
// //         _currentState = CategoryState.calendar; 
// //         return;
// //       }

// //       if (value == "⌫") {
// //         if (_amount != "0" && _amount != "Error") {
// //           if (_amount.length > 1) {
// //             _amount = _amount.substring(0, _amount.length - 1);
// //           } else {
// //             _amount = "0";
// //           }
// //         }
// //         return;
// //       }

// //       if (value == "+" || value == "-" || value == "×" || value == "÷") {
// //         if (_amount == "Error") return;
        
// //         if (_currentOperator != null && !_shouldResetDisplay) {
// //           _calculateResult(); 
// //         }
        
// //         _firstOperand = double.tryParse(_amount);
// //         _currentOperator = value;
// //         _expression = "${_amount} ${_currentOperator}"; 
// //         _shouldResetDisplay = true; 
// //         return;
// //       }

// //       if (value == "=") {
// //         if (_currentOperator != null) {
// //           _expression = "$_expression $_amount ="; 
// //           _calculateResult();
// //         }
// //         return;
// //       }

// //       if (value == "✓") {
// //         double parsedAmount = double.tryParse(_amount) ?? 0.0;
// //         if (parsedAmount == 0.0 || _amount == "0" || _amount == "Error") return;

// //         if (_selectedCategory != null) {
// //           String userNote = _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : "No note";
          
// //           BlocProvider.of<TransactionBloc>(context).add(
// //             AddTransactionRequested(
// //               categoryId: _selectedCategory!.id,
// //               amount: parsedAmount,
// //               note: userNote,
// //             ),
// //           );
// //           BlocProvider.of<TransactionBloc>(context).add(LoadTransactions());
// //           BlocProvider.of<CategoryBloc>(context).add(LoadCategories()); 
// //         }
        
// //         _amount = "0"; _expression = ""; _firstOperand = null; _currentOperator = null; _shouldResetDisplay = false;
// //         _noteController.clear(); _pickedImage = null; _selectedCategory = null;
// //         _currentState = CategoryState.view;
// //         return;
// //       }

// //       if (value == ".") {
// //         if (_shouldResetDisplay || _amount == "Error") {
// //           _amount = "0."; _shouldResetDisplay = false;
// //         } else if (!_amount.contains(".")) {
// //           _amount += ".";
// //         }
// //         return;
// //       }

// //       if (_shouldResetDisplay || _amount == "Error") {
// //         _amount = value; _shouldResetDisplay = false;
// //       } else {
// //         if (_amount == "0") {
// //           _amount = value; 
// //         } else {
// //           _amount += value; 
// //         }
// //       }
// //     });
// //   }

// // void _calculateResult() {
// //     if (_firstOperand == null || _currentOperator == null) return;
    
// //     double secondOperand = double.tryParse(_amount) ?? 0;
// //     double result = 0;

// //     switch (_currentOperator) {
// //       case "+": result = _firstOperand! + secondOperand; break;
// //       case "-": result = _firstOperand! - secondOperand; break;
// //       case "×": result = _firstOperand! * secondOperand; break;
// //       case "÷":
// //         if (secondOperand != 0) {
// //           result = _firstOperand! / secondOperand;
// //         } else {
// //           _amount = "Error"; _expression = ""; _firstOperand = null; _currentOperator = null;
// //           return;
// //         }
// //         break;
// //     }

// //     if (result % 1 == 0) {
// //       _amount = result.toInt().toString();
// //     } else {
// //       _amount = result.toStringAsFixed(2); 
// //     }
    
// //     _firstOperand = null;
// //     _currentOperator = null;
// //     _expression = ""; 
// //   }
// //   void _showActionBottomSheet(CategoryItem item) {
// //     showModalBottomSheet(
// //       context: context,
// //       backgroundColor: Colors.transparent,
// //       builder: (context) => Container(
// //         padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
// //         decoration: const BoxDecoration(
// //           color: Color(0xFFF7F5FC),
// //           borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
// //         ),
// //         child: SafeArea(
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               ListTile(
// //                 leading: const Icon(Icons.edit_outlined, color: Color(0xFF6366F1)),
// //                 title: const Text('Edit Category', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1F2937))),
// //                 onTap: () {
// //                   Navigator.pop(context);
// //                   setState(() {
// //                     _itemToModify = item;
// //                     _nameController.text = item.name;
// //                     _tempColor = item.color;
// //                     _tempIcon = item.icon;
// //                     _tempType = item.type == 'expense' ? "Expense" : "Income";
// //                     _currentState = CategoryState.edit;
// //                   });
// //                 },
// //               ),
// //               const Divider(color: Color(0xFFE5E7EB), height: 1),
// //               ListTile(
// //                 leading: const Icon(Icons.delete_outline, color: Color(0xFFF87171)),
// //                 title: const Text('Delete Category', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1F2937))),
// //                 onTap: () {
// //                   Navigator.pop(context);
// //                   setState(() {
// //                     _itemToModify = item;
// //                     _currentState = CategoryState.deleteConfirm;
// //                   });
// //                 },
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final double screenWidth = MediaQuery.of(context).size.width;
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFE8DEF8), // Top area header color
// //       resizeToAvoidBottomInset: true,
// //       body: SafeArea(
// //         child: LayoutBuilder(
// //           builder: (context, constraints) {
// //             return Column(
// //               children: [
// //                 _buildAppBar(), 
// //                 Expanded(
// //                   child: Stack(
// //                     children: [
// //                       if (_currentState == CategoryState.view || 
// //                           _currentState == CategoryState.calculator || 
// //                           _currentState == CategoryState.deleteConfirm)
// //                         Column(
// //                           children: [
// //                             Padding(
// //                               padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
// //                               child: Container(
// //                                 height: 40,
// //                                 decoration: BoxDecoration(
// //                                   color: Colors.white,
// //                                   borderRadius: BorderRadius.circular(12),
// //                                 ),
// //                                 child: TabBar(
// //                                   controller: _tabController,
// //                                   labelColor: Colors.white, 
// //                                   unselectedLabelColor: const Color(0xFF4B5563), 
// //                                   indicatorSize: TabBarIndicatorSize.tab,
// //                                   indicator: BoxDecoration(
// //                                     borderRadius: BorderRadius.circular(12),
// //                                     color: const Color(0xFF7F3DFF),
// //                                   ),
// //                                   tabs: const [
// //                                     Tab(
// //                                       child: Center(
// //                                         child: Text("Expense", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
// //                                       ),
// //                                     ),
// //                                     Tab(
// //                                       child: Center(
// //                                         child: Text("Income", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ),
// //                             Expanded(
// //                               child: TabBarView(
// //                                 controller: _tabController,
// //                                 physics: const NeverScrollableScrollPhysics(), 
// //                                 children: [
// //                                   _buildCategoryListFiltered(type: 'expense'),
// //                                   _buildCategoryListFiltered(type: 'income'),
// //                                 ],
// //                               ),
// //                             ),
// //                           ],
// //                         ),

// //                       if (_currentState == CategoryState.calculator) _buildCalculatorSection(screenWidth),
// //                       if (_currentState == CategoryState.deleteConfirm) _buildDeleteAlertBox(screenWidth),
// //                       if (_currentState == CategoryState.add) _buildAddCategoryView(constraints),
// //                       if (_currentState == CategoryState.edit) _buildEditCategoryView(constraints),
// //                       if (_currentState == CategoryState.calendar) _buildCalendarView(screenWidth),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }
// // Widget _buildAppBar() {
// //     String title = "Categories";
// //     if (_currentState == CategoryState.add) title = "Add New Category";
// //     if (_currentState == CategoryState.edit) title = "Edit Category";
// //     if (_currentState == CategoryState.calendar) title = "Calendar"; 

// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           GestureDetector(
// //             onTap: () {
// //               if (_currentState == CategoryState.view) {
// //                 if (widget.onBackToHome != null) {
// //                   widget.onBackToHome!(); 
// //                 }
// //               } else if (_currentState == CategoryState.calendar) {
// //                 setState(() => _currentState = CategoryState.calculator);
// //               } else {
// //                 setState(() => _currentState = CategoryState.view);
// //               }
// //             },
// //             child: Container(
// //               padding: const EdgeInsets.all(8),
// //               decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
// //               child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF1F2937)),
// //             ),
// //           ),
// //           Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          
// //           if (_currentState == CategoryState.calendar)
// //             GestureDetector(
// //               onTap: () async {
// //                 final DateTime? picked = await showDatePicker(
// //                   context: context,
// //                   initialDate: _currentSelectedCalendarDate,
// //                   firstDate: DateTime(2020),
// //                   lastDate: DateTime(2030),
// //                   initialDatePickerMode: DatePickerMode.year, 
// //                   helpText: "SELECT MONTH & YEAR",
// //                 );
// //                 if (picked != null) {
// //                   setState(() {
// //                     _currentSelectedCalendarDate = DateTime(picked.year, picked.month, 1);
// //                   });
// //                 }
// //               },
// //               child: Container(
// //                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                 decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(4)),
// //                 child: Row(
// //                   children: [
// //                     Text(
// //                       DateFormat('MMM/yyyy').format(_currentSelectedCalendarDate),
// //                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
// //                     ),
// //                     const SizedBox(width: 2),
// //                     const Icon(Icons.unfold_more, size: 18, color: Colors.black), 
// //                   ],
// //                 ),
// //               ),
// //             )
// //          else if (_currentState == CategoryState.calculator)
// //             // 🌟 Close(X) အစား ✓ အမှန်ခြစ်ခလုတ်ကို အပေါ်တွင် ပြသခြင်း (Error မရှိတော့ပါ)
// //             GestureDetector(
// //               onTap: () => _onKeypadPressed("✓"), 
// //               child: Container(
// //                 padding: const EdgeInsets.all(8),
// //                 decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
// //                 child: const Icon(Icons.check, size: 18, color: Color(0xFF10B981)), // ပြင်ဆင်ပြီး
// //               ),
// //             )
// //           else
// //             GestureDetector(
// //               onTap: () => setState(() {
// //                 _selectedCategory = null; 
// //                 _currentState = CategoryState.view;
// //               }),
// //               child: Container(
// //                 padding: const EdgeInsets.all(8),
// //                 decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
// //                 child: const Icon(Icons.close, size: 16, color: Color(0xFF1F2937)),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
  
// //   Widget _buildCategoryListFiltered({required String type}) {
// //     return BlocConsumer<CategoryBloc, CategoryStateBase>(
// //       listener: (context, state) {
// //         if (state is CategoryError) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(content: Text(state.message), backgroundColor: Colors.black),
// //           );
// //         }
// //       },
// //       builder: (context, state) {
// //         if (state is CategoryLoading) {
// //           return const Center(child: CircularProgressIndicator(color: Color(0xFF7F3DFF)));
// //         }

// //         List<CategoryItem> currentCategories = [];
// //         if (state is CategoryLoaded) {
// //           currentCategories = state.categories.where((c) => c.type == type).toList();
// //         }

// //         return ListView.builder(
// //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //           itemCount: currentCategories.length + 1,
// //           itemBuilder: (context, index) {
// //             if (index == currentCategories.length) {
// //               return Container(
// //                 margin: const EdgeInsets.only(bottom: 12),
// //                 decoration: BoxDecoration(
// //                   color: const Color(0xFFF9FAFB),
// //                   borderRadius: BorderRadius.circular(16),
// //                 ),
// //                 child: ListTile(
// //                   contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
// //                   leading: const Icon(Icons.add, color: Colors.black, size: 24),
// //                   title: const Text("Add New Category", 
// //                       style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15)),
// //                   onTap: () => setState(() {
// //                     _nameController.clear();
// //                     _tempColor = const Color(0xFFF59E0B);
// //                     _tempIcon = Icons.restaurant;
// //                     _tempType = type == 'expense' ? "Expense" : "Income"; 
// //                     _currentState = CategoryState.add;
// //                   }),
// //                 ),
// //               );
// //             }

// //             final item = currentCategories[index];
// //             return Container(
// //               margin: const EdgeInsets.only(bottom: 12),
// //               decoration: BoxDecoration(
// //                 color: const Color(0xFFF9FAFB),
// //                 borderRadius: BorderRadius.circular(16),
// //               ),
// //               child: ListTile(
// //                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
// //                 onTap: () => setState(() {
// //                   _selectedCategory = item;
// //                   _amount = "0"; _expression = ""; _firstOperand = null; _currentOperator = null; _shouldResetDisplay = false;
// //                   _currentState = CategoryState.calculator;
// //                 }),
// //                leading: Container(
// //   padding: const EdgeInsets.all(2), 
// //   decoration: BoxDecoration(
// //     shape: BoxShape.circle,
// //     border: _selectedCategory == item 
// //         ? Border.all(color: Colors.black, width: 2) 
// //         : null,
// //   ),
// //   child: CircleAvatar(
// //     radius: 20,
// //     backgroundColor: item.color,
// //     child: Icon(item.icon, color: Colors.white, size: 20),
// //   ),
// // ),
// //                 title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 15)),
// //                 trailing: IconButton(
// //                   icon: const Icon(Icons.more_vert, size: 22, color: Color(0xFF9CA3AF)),
// //                   onPressed: () => _showActionBottomSheet(item),
// //                 ),
// //               ),
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }
// // Widget _buildCalculatorSection(double screenWidth) {
// //     return Align(
// //       alignment: Alignment.bottomCenter,
// //       child: Container(
// //         color: const Color(0xFFF7F5FC),
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           crossAxisAlignment: CrossAxisAlignment.end,
// //           children: [
// //             if (_expression.isNotEmpty)
// //               Padding(
// //                 padding: const EdgeInsets.only(bottom: 4.0),
// //                 child: Text(_expression, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
// //               ),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 if (_selectedCategory != null)
// //                   // 🌟 Icon ဘေးတွင် Category Name တွဲလျက်ပြသရန် Row ပြောင်းလဲထားပါသည်
// //                   Row(
// //                     children: [
// //                       Container(
// //                         padding: const EdgeInsets.all(2),
// //                         decoration: BoxDecoration(
// //                           shape: BoxShape.circle,
// //                           border: Border.all(color: Colors.black, width: 1.8),
// //                         ),
// //                         child: CircleAvatar(
// //                           radius: 16,
// //                           backgroundColor: _selectedCategory!.color,
// //                           child: Icon(_selectedCategory!.icon, color: Colors.white, size: 16),
// //                         ),
// //                       ),
// //                       const SizedBox(width: 8),
// //                       Text(
// //                         _selectedCategory!.name,
// //                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
// //                       ),
// //                     ],
// //                   )
// //                 else
// //                   const Icon(Icons.article_outlined, color: Color(0xFF4B5563), size: 28),

// //                 Text(_amount, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
// //               ],
// //             ),
// //             const SizedBox(height: 12),
// //             TextField(
// //               controller: _noteController,
// //               decoration: InputDecoration(
// //                 hintText: "Note: Enter a note ......",
// //                 hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14),
// //                 filled: true,
// //                 fillColor: const Color(0xFFF7F5FC),
// //                 // 🌟 Camera Icon အား ဖြုတ်လိုက်ပါပြီ
// //                 enabledBorder: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(4),
// //                   borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
// //                 ),
// //                 focusedBorder: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(4),
// //                   borderSide: const BorderSide(color: Color(0xFF7F3DFF), width: 2),
// //                 ),
// //                 contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// //               ),
// //             ),
// //             const SizedBox(height: 12),
// //             _buildBalancedKeypadUI(), 
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // Widget _buildBalancedKeypadUI() {
// //     return LayoutBuilder(
// //       builder: (context, constraints) {
// //         double cellHeight = 44; 

// //         return GridView.count(
// //           shrinkWrap: true,
// //           physics: const NeverScrollableScrollPhysics(),
// //           crossAxisCount: 4, 
// //           mainAxisSpacing: 8,
// //           crossAxisSpacing: 10,
// //           childAspectRatio: (constraints.maxWidth / 4) / cellHeight,
// //           children: [
// //             _buildBaseButton("7"), _buildBaseButton("8"), _buildBaseButton("9"), _buildActionButton("Today"),
// //             _buildBaseButton("4"), _buildBaseButton("5"), _buildBaseButton("6"), 
// //             Row(
// //               children: [
// //                 Expanded(child: _buildActionButton("+")),
// //                 const SizedBox(width: 6),
// //                 Expanded(child: _buildActionButton("-")),
// //               ],
// //             ),
// //             _buildBaseButton("1"), _buildBaseButton("2"), _buildBaseButton("3"), 
// //             Row(
// //               children: [
// //                 Expanded(child: _buildActionButton("×")),
// //                 const SizedBox(width: 6),
// //                 Expanded(child: _buildActionButton("÷")),
// //               ],
// //             ),
// //             _buildBaseButton("."), _buildBaseButton("0"), _buildActionButton("⌫"), 
// //             _buildActionButton("="), // 🌟 "✓" နေရာတွင် "=" သို့ ပြောင်းလဲထားပါသည်
// //           ],
// //         );
// //       },
// //     );
// //   }
// //   Widget _buildActionButton(String label) {
// //     bool isEqual = label == "=";
// //     bool isToday = label == "Today";

// //     return GestureDetector(
// //       onTap: () {
// //         // 🌟 "=" ခလုတ်ကို နှိပ်လိုက်ရင် ရှေ့က Operator တွေရှိနေရင် အရင်တွက်ချက်ပေးဖို့ Logic ထည့်ထားပါတယ်
// //         if (isEqual && _currentOperator != null) {
// //           _calculateResult();
// //         }
// //         _onKeypadPressed(label);
// //       },
// //       child: Container(
// //         decoration: BoxDecoration(
// //           color: const Color(0xFFEDE9FE),
// //           borderRadius: BorderRadius.circular(6),
// //         ),
// //         child: Center(
// //           child: Text(
// //             label, 
// //             style: TextStyle(
// //               fontSize: isToday ? 13 : 20, 
// //               fontWeight: FontWeight.w600, 
// //               color: isEqual ? const Color(0xFF7F3DFF) : Colors.black,
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildBaseButton(String label) {
// //     return GestureDetector(
// //       onTap: () => _onKeypadPressed(label),
// //       child: Container(
// //         decoration: BoxDecoration(
// //           color: const Color(0xFFEDE9FE), 
// //           borderRadius: BorderRadius.circular(6),
// //         ),
// //         child: Center(
// //           child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
// //         ),
// //       ),
// //     );
// //   }
// //   Widget _buildDeleteAlertBox(double screenWidth) {
// //     return Container(
// //       color: Colors.black38,
// //       alignment: Alignment.center,
// //       child: Container(
// //         width: screenWidth * 0.82,
// //         padding: const EdgeInsets.all(24),
// //         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             const Text(
// //               "Are you sure you want to delete?",
// //               textAlign: TextAlign.center,
// //               style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 16),
// //             ),
// //             const SizedBox(height: 24),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //               children: [
// //                 TextButton(
// //                   onPressed: () => setState(() => _currentState = CategoryState.view),
// //                   child: const Text("Cancel", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
// //                 ),
// //                 TextButton(
// //                   onPressed: () {
// //                     if (_itemToModify != null) {
// //                       BlocProvider.of<CategoryBloc>(context).add(DeleteCategoryRequested(_itemToModify!.id));
// //                       BlocProvider.of<TransactionBloc>(context).add(LoadTransactions());
// //                       _selectedCategory = null;
// //                       _itemToModify = null;
// //                       setState(() => _currentState = CategoryState.view);
// //                     }
// //                   },
// //                   child: const Text("Confirm", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
// //                 ),
// //               ],
// //             )
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildAddCategoryView(BoxConstraints constraints) {
// //     return Container(
// //       color: Colors.white, 
// //       height: double.infinity,
// //       width: double.infinity,
// //       child: SingleChildScrollView(
// //         physics: const BouncingScrollPhysics(),
// //         child: Padding(
// //           padding: const EdgeInsets.all(20.0),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               _buildFormInputs(isDisableType: true), 
// //               const SizedBox(height: 24),
// //               const Text("Choose Colour", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
// //               const SizedBox(height: 14),
// //               _buildColorPicker(),
// //               const SizedBox(height: 28),
// //               const Text("Choose Icon", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
// //               const SizedBox(height: 14),
              
// //               _buildIconGrid(constraints),
              
// //               const SizedBox(height: 32), 
              
// //               _buildSaveButton(
// //                 label: "Save",
// //                 onPressed: () {
// //                   if (_nameController.text.isNotEmpty) {
// //                     BlocProvider.of<CategoryBloc>(context).add(
// //                       AddCategoryRequested(
// //                         name: _nameController.text.trim(),
// //                         icon: _tempIcon,
// //                         color: _tempColor,
// //                         type: _tempType.toLowerCase(),
// //                       ),
// //                     );
// //                     setState(() => _currentState = CategoryState.view);
// //                   }
// //                 },
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildEditCategoryView(BoxConstraints constraints) {
// //     return Container(
// //       color: Colors.white, 
// //       height: double.infinity,
// //       width: double.infinity,
// //       padding: const EdgeInsets.all(20.0),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           _buildFormInputs(isDisableType: true), 
// //           const SizedBox(height: 24),
// //           const Text("Choose Colour", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
// //           const SizedBox(height: 14),
// //           _buildColorPicker(),
// //           const Spacer(),
// //           Row(
// //             children: [
// //               Expanded(
// //                 child: SizedBox(
// //                   height: 48,
// //                   child: OutlinedButton(
// //                     style: OutlinedButton.styleFrom(
// //                       side: const BorderSide(color: Color(0xFF7F3DFF), width: 1.5),
// //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //                     ),
// //                     onPressed: () => setState(() => _currentState = CategoryState.view),
// //                     child: const Text("Cancel", style: TextStyle(color: Color(0xFF7F3DFF), fontSize: 16, fontWeight: FontWeight.bold)),
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(width: 16),
// //               Expanded(
// //                 child: _buildSaveButton(
// //                   label: "Done",
// //                   onPressed: () {
// //                     if (_nameController.text.isNotEmpty && _itemToModify != null) {
// //                       BlocProvider.of<CategoryBloc>(context).add(
// //                         UpdateCategoryRequested(
// //                           id: _itemToModify!.id,
// //                           name: _nameController.text.trim(),
// //                           icon: _tempIcon,
// //                           color: _tempColor,
// //                           type: _tempType.toLowerCase(),
// //                         ),
// //                       );
// //                       _nameController.clear();
// //                       _itemToModify = null;
// //                       setState(() => _currentState = CategoryState.view);
// //                     }
// //                   },
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildCalendarView(double screenWidth) {
// //     final List<String> weekdays = ["S", "M", "T", "W", "T", "F", "S"];
    
// //     final DateTime now = _currentSelectedCalendarDate;
// //     final int year = now.year;
// //     final int month = now.month;

// //     final DateTime firstDayOfMonth = DateTime(year, month, 1);
// //     final int daysInMonth = DateTime(year, month + 1, 0).day;
// //     final int firstWeekdayIndex = firstDayOfMonth.weekday % 7; 
// //     final int daysInPrevMonth = DateTime(year, month, 0).day;

// //     final List<Map<String, dynamic>> calendarDays = [];

   
// //     for (int i = firstWeekdayIndex - 1; i >= 0; i--) {
// //       calendarDays.add({
// //         "day": daysInPrevMonth - i,
// //         "isCurrentMonth": false,
// //         "date": DateTime(year, month - 1, daysInPrevMonth - i)
// //       });
// //     }

    
// //     for (int i = 1; i <= daysInMonth; i++) {
// //       calendarDays.add({
// //         "day": i,
// //         "isCurrentMonth": true,
// //         "date": DateTime(year, month, i)
// //       });
// //     }

// //     int totalSlots = 42; 
// //     int nextMonthDay = 1;
// //     while (calendarDays.length < totalSlots) {
// //       calendarDays.add({
// //         "day": nextMonthDay,
// //         "isCurrentMonth": false,
// //         "date": DateTime(year, month + 1, nextMonthDay)
// //       });
// //       nextMonthDay++;
// //     }

// //     return Container(
// //       color: Colors.white, 
// //       padding: const EdgeInsets.symmetric(horizontal: 16),
// //       child: Column(
// //         children: [
// //           const SizedBox(height: 20),
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceAround,
// //             children: weekdays.map((w) => SizedBox(
// //               width: screenWidth / 8,
// //               child: Text(
// //                 w, 
// //                 textAlign: TextAlign.center, 
// //                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)
// //               ),
// //             )).toList(),
// //           ),
// //           const SizedBox(height: 16),
// //           Expanded(
// //             child: GridView.builder(
// //               itemCount: calendarDays.length,
// //               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //                 crossAxisCount: 7, 
// //                 mainAxisSpacing: 14, 
// //                 crossAxisSpacing: 10,
// //               ),
// //               itemBuilder: (context, index) {
// //                 final dayData = calendarDays[index];
// //                 final int dayNumber = dayData["day"];
// //                 final bool isCurrentMonth = dayData["isCurrentMonth"];
// //                 final DateTime cellDate = dayData["date"];

// //                 bool isSelectedDay = isCurrentMonth && 
// //                     (cellDate.day == _currentSelectedCalendarDate.day) &&
// //                     (cellDate.month == _currentSelectedCalendarDate.month) &&
// //                     (cellDate.year == _currentSelectedCalendarDate.year);

// //                 return GestureDetector(
// //   key: ValueKey(cellDate.toString()), 
// //   onTap: () {
// //     setState(() {
// //       _currentSelectedCalendarDate = cellDate;
// //       _calendarHeaderText = DateFormat('EEE, MMM d, yyyy').format(_currentSelectedCalendarDate);
// //       _currentState = CategoryState.calculator; 
// //     });
// //   },
// //   child: Container(
// //     decoration: BoxDecoration(
// //       color: isSelectedDay ? const Color(0xFF7F3DFF) : Colors.transparent,
// //       shape: BoxShape.circle,
// //                     ),
// //     alignment: Alignment.center,
// //     child: Text(
// //       dayNumber.toString(),
// //       style: TextStyle(
// //         fontSize: 16,
// //         fontWeight: isSelectedDay ? FontWeight.bold : FontWeight.w600,
// //         color: isSelectedDay 
// //             ? Colors.white 
// //             : (isCurrentMonth ? Colors.black : const Color(0xFF9CA3AF)),
// //       ),
// //     ),
// //   ),
// // );
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildFormInputs({bool isDisableType = false}) {
// //     return Column(
// //       children: [
// //         ListTile(
// //           contentPadding: EdgeInsets.zero,
// //           title: const Text("Icon", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
// //           trailing: Stack(
// //             alignment: Alignment.bottomRight,
// //             children: [
// //               CircleAvatar(backgroundColor: _tempColor, radius: 24, child: Icon(_tempIcon, color: Colors.white, size: 24)),
// //               Container(
// //                 padding: const EdgeInsets.all(2),
// //                 decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
// //                 child: const Icon(Icons.edit, size: 10, color: Colors.black),
// //               )
// //             ],
// //           ),
// //         ),
// //         const SizedBox(height: 10),
// //         ListTile(
// //           contentPadding: EdgeInsets.zero,
// //           title: const Text("Name", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
// //           trailing: SizedBox(
// //             width: 180,
// //             child: TextField(
// //               controller: _nameController,
// //               textAlign: TextAlign.end,
// //               style: const TextStyle(fontSize: 15, color: Colors.black),
// //               decoration: const InputDecoration(
// //                 hintText: "Enter category name...",
// //                 border: InputBorder.none,
// //                 suffixIcon: Icon(Icons.edit, size: 16, color: Color(0xFF9CA3AF)),
// //               ),
// //             ),
// //           ),
// //         ),
// //         const SizedBox(height: 10),
// //         ListTile(
// //           contentPadding: EdgeInsets.zero,
// //           title: const Text("Type", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
// //           trailing: Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 12.0),
// //             child: Text(_tempType, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 16)),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildColorPicker() {
// //     return SizedBox(
// //       height: 46,
// //       child: ListView.builder(
// //         scrollDirection: Axis.horizontal,
// //         itemCount: _availableColors.length,
// //         itemBuilder: (context, index) {
// //           final color = _availableColors[index];
// //           bool isSelected = _tempColor == color;
// //           return GestureDetector(
// //             onTap: () => setState(() => _tempColor = color),
// //             child: Container(
// //               margin: const EdgeInsets.symmetric(horizontal: 6),
// //               width: 40,
// //               decoration: BoxDecoration(
// //                 color: color,
// //                 shape: BoxShape.circle,
// //                 border: isSelected ? Border.all(color: const Color(0xFFF472B6), width: 3) : null,
// //               ),
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   Widget _buildIconGrid(BoxConstraints constraints) {
// //     return GridView.builder(
// //       shrinkWrap: true,
// //       physics: const NeverScrollableScrollPhysics(),
// //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //         crossAxisCount: 5, mainAxisSpacing: 16, crossAxisSpacing: 16
// //       ),
// //       itemCount: _availableIcons.length,
// //       itemBuilder: (context, index) {
// //         final icon = _availableIcons[index];
// //         bool isSelected = _tempIcon == icon;
// //         return GestureDetector(
// //           onTap: () => setState(() => _tempIcon = icon),
// //           child: CircleAvatar(
// //             backgroundColor: isSelected ? const Color(0xFFFCE7F3) : const Color(0xFFE5E7EB),
// //             child: Icon(icon, color: isSelected ? const Color(0xFFEC4899) : const Color(0xFF6B7280)),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildSaveButton({required String label, required VoidCallback onPressed}) {
// //     return SizedBox(
// //       width: double.infinity,
// //       height: 48,
// //       child: ElevatedButton(
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: const Color(0xFF7F3DFF),
// //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //           elevation: 0,
// //         ),
// //         onPressed: onPressed,
// //         child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
// //       ),
// //     );
// //   }
// // }


// import 'package:expense_tracker/features/auth/presentation/bloc/category_bloc.dart';
// import 'package:expense_tracker/features/auth/presentation/bloc/category_event.dart';
// import 'package:expense_tracker/features/auth/presentation/bloc/category_state.dart';
// import 'package:expense_tracker/features/auth/presentation/bloc/transaction_bloc.dart';
// import 'package:expense_tracker/features/auth/presentation/bloc/transaction_event.dart';
// import 'package:expense_tracker/models/category_model.dart';
// import 'package:expense_tracker/models/record_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';

// List<RecordItem> globalRecords = [];
// enum CategoryState { view, calculator, deleteConfirm, add, edit, calendar }

// class CategoryScreen extends StatefulWidget {
//   final VoidCallback? onBackToHome; 

//   const CategoryScreen({Key? key, this.onBackToHome}) : super(key: key);

//   @override
//   State<CategoryScreen> createState() => _CategoryScreenState();
// }

// class _CategoryScreenState extends State<CategoryScreen> with SingleTickerProviderStateMixin {
//   CategoryState _currentState = CategoryState.view;
//   int _currentTabIndex = 2;
  
//   late TabController _tabController;

//   String _amount = "0";             
//   String _expression = "";          
//   bool _shouldResetDisplay = false; 

//   // Colors aligned with screenshots
//   final List<Color> _availableColors = [
//     const Color(0xFF6366F1), const Color(0xFF10B981), const Color(0xFFF59E0B),
//     const Color(0xFFEF4444), const Color(0xFFEC4899), const Color(0xFF06B6D4),
//     const Color(0xFF8B5CF6), const Color(0xFF14B8A6), const Color(0xFFF43F5E),
//     const Color(0xFF84CC16), const Color(0xFF3B82F6), const Color(0xFFEAB308),
//     const Color(0xFF6B7280), const Color(0xFF9A3412), const Color(0xFFF3ED5A),
//   ];

//   final List<IconData> _availableIcons = [
//     Icons.restaurant, Icons.shopping_bag, Icons.directions_car, Icons.home,
//     Icons.local_hospital, Icons.school, Icons.flight, Icons.movie,
//     Icons.fitness_center, Icons.dry_cleaning, Icons.pets, Icons.wifi,
//     Icons.build, Icons.card_giftcard, Icons.attach_money, Icons.payments,
//     Icons.trending_up, Icons.storefront, Icons.account_balance, Icons.calendar_month_outlined,    
//     Icons.handshake, Icons.phone, Icons.school_outlined, Icons.music_note_outlined,
//     Icons.headphones, Icons.local_cafe, Icons.health_and_safety, Icons.computer,
//   ];

//   CategoryItem? _selectedCategory;
//   CategoryItem? _itemToModify;
  
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _noteController = TextEditingController();
  
//   Color _tempColor = const Color(0xFFF59E0B);
//   IconData _tempIcon = Icons.restaurant;
//   String _tempType = "Expense"; 
  
//   String _calendarHeaderText = "";
//   DateTime _currentSelectedCalendarDate = DateTime.now();

//   @override
//   void initState() {
//     super.initState();
//     _calendarHeaderText = DateFormat('EEE, MMM d, yyyy').format(DateTime.now());
//     _tabController = TabController(length: 2, vsync: this);
    
//     _tabController.addListener(() {
//       if (!_tabController.indexIsChanging) {
//         setState(() {});
//       }
//     });
    
//     BlocProvider.of<CategoryBloc>(context).add(LoadCategories());
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _noteController.dispose();
//     _tabController.dispose();
//     super.dispose();
//   }

//   void _onKeypadPressed(String value) {
//     setState(() {
//       if (value == "Today") {
//         _currentSelectedCalendarDate = DateTime.now();
//         _calendarHeaderText = DateFormat('EEE, MMM d, yyyy').format(_currentSelectedCalendarDate);
//         _currentState = CategoryState.calendar; 
//         return;
//       }

//       if (value == "⌫") {
//         if (_amount != "0" && _amount != "Error") {
//           if (_amount.length > 1) {
//             _amount = _amount.substring(0, _amount.length - 1);
//           } else {
//             _amount = "0";
//           }
//         }
//         return;
//       }

//       if (value == "+" || value == "-" || value == "×" || value == "÷") {
//         if (_amount == "Error") return;
        
//         // အကယ်၍ ပြီးခဲ့တဲ့အဆင့်မှာ = နှိပ်ပြီးသားဖြစ်နေရင် အဖြေပေါ်မူတည်ပြီး Expression အသစ်ပြန်စမယ်
//         if (_expression.contains("=")) {
//           _expression = "${_amount} ${value}";
//         } else {
//           // ဂဏန်းတွေအများကြီး ဆက်တိုက်ပေါင်းနိုင်ရန် လက်ရှိ Amount ကို Expression ထဲ ပေါင်းထည့်ခြင်း
//           _expression = _expression.isEmpty ? "${_amount} ${value}" : "${_expression} ${_amount} ${value}";
//         }
        
//         _shouldResetDisplay = true; 
//         return;
//       }

//       if (value == "=") {
//         if (_expression.isNotEmpty && !_expression.contains("=")) {
//           String fullExpression = "$_expression $_amount";
//           _calculateAdvancedResult(fullExpression);
//         }
//         return;
//       }

//       if (value == "✓") {
//         double parsedAmount = double.tryParse(_amount) ?? 0.0;
//         if (parsedAmount == 0.0 || _amount == "0" || _amount == "Error") return;

//         if (_selectedCategory != null) {
//           String userNote = _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : "No note";
          
//           BlocProvider.of<TransactionBloc>(context).add(
//             AddTransactionRequested(
//               categoryId: _selectedCategory!.id,
//               amount: parsedAmount,
//               note: userNote,
//             ),
//           );
//           BlocProvider.of<TransactionBloc>(context).add(LoadTransactions());
//           BlocProvider.of<CategoryBloc>(context).add(LoadCategories()); 
//         }
        
//         _amount = "0"; _expression = ""; _shouldResetDisplay = false;
//         _noteController.clear(); _selectedCategory = null;
//         _currentState = CategoryState.view;
//         return;
//       }

//       if (value == ".") {
//         if (_shouldResetDisplay || _amount == "Error") {
//           _amount = "0."; _shouldResetDisplay = false;
//         } else if (!_amount.contains(".")) {
//           _amount += ".";
//         }
//         return;
//       }

//       if (_shouldResetDisplay || _amount == "Error") {
//         _amount = value; _shouldResetDisplay = false;
//       } else {
//         if (_amount == "0") {
//           _amount = value; 
//         } else {
//           _amount += value; 
//         }
//       }
//     });
//   }

//   // 🌟 Operator Precedence (+-*/ ဆင့်ကဲအတွဲအများကြီး) အတိုင်း တိကျစွာတွက်ချက်ပေးမည့် Parser Logic
//   void _calculateAdvancedResult(String expr) {
//     try {
//       List<String> tokens = expr.split(" ");
//       List<double> numbers = [];
//       List<String> operators = [];

//       // ၁။ ကိန်းဂဏန်းများနှင့် Operator များကို ခွဲထုတ်ခြင်း
//       for (var token in tokens) {
//         if (token == "+" || token == "-" || token == "×" || token == "÷") {
//           operators.add(token);
//         } else {
//           numbers.add(double.tryParse(token) ?? 0.0);
//         }
//       }

//       if (numbers.length != operators.length + 1) {
//         _amount = "Error"; _expression = ""; return;
//       }

//       // ၂။ ပထမအဆင့် - ဦးစားပေးဖြစ်သော မြှောက်ခြင်း (×) နှင့် စားခြင်း (÷) များကို အရင်ရှင်းခြင်း
//       for (int i = 0; i < operators.length; ) {
//         if (operators[i] == "×" || operators[i] == "÷") {
//           double num1 = numbers[i];
//           double num2 = numbers[i + 1];
//           double res = 0;

//           if (operators[i] == "×") {
//             res = num1 * num2;
//           } else {
//             if (num2 == 0) {
//               _amount = "Error"; _expression = ""; return;
//             }
//             res = num1 / num2;
//           }

//           numbers[i] = res;
//           numbers.removeAt(i + 1);
//           operators.removeAt(i);
//         } else {
//           i++;
//         }
//       }

//       // ၃။ ဒုတိယအဆင့် - ကျန်ရှိနေသော ပေါင်းခြင်း (+) နှင့် နှုတ်ခြင်း (-) များကို ဘယ်မှညာ အစဉ်လိုက်ရှင်းခြင်း
//       double finalResult = numbers[0];
//       for (int i = 0; i < operators.length; i++) {
//         double nextNum = numbers[i + 1];
//         if (operators[i] == "+") {
//           finalResult += nextNum;
//         } else if (operators[i] == "-") {
//           finalResult -= nextNum;
//         }
//       }

//       // ၄။ ရလဒ်အား Format ပြုပြင်ပြီး Display ပေါ်တင်ခြင်း
//       setState(() {
//         if (finalResult % 1 == 0) {
//           _amount = finalResult.toInt().toString();
//         } else {
//           _amount = finalResult.toStringAsFixed(2);
//         }
//         _expression = "$expr = $_amount";
//         _shouldResetDisplay = true;
//       });
//     } catch (e) {
//       _amount = "Error";
//       _expression = "";
//     }
//   }

//   void _showActionBottomSheet(CategoryItem item) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//         decoration: const BoxDecoration(
//           color: Color(0xFFF7F5FC),
//           borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
//         ),
//         child: SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.edit_outlined, color: Color(0xFF6366F1)),
//                 title: const Text('Edit Category', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1F2937))),
//                 onTap: () {
//                   Navigator.pop(context);
//                   setState(() {
//                     _itemToModify = item;
//                     _nameController.text = item.name;
//                     _tempColor = item.color;
//                     _tempIcon = item.icon;
//                     _tempType = item.type == 'expense' ? "Expense" : "Income";
//                     _currentState = CategoryState.edit;
//                   });
//                 },
//               ),
//               const Divider(color: Color(0xFFE5E7EB), height: 1),
//               ListTile(
//                 leading: const Icon(Icons.delete_outline, color: Color(0xFFF87171)),
//                 title: const Text('Delete Category', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1F2937))),
//                 onTap: () {
//                   Navigator.pop(context);
//                   setState(() {
//                     _itemToModify = item;
//                     _currentState = CategoryState.deleteConfirm;
//                   });
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       backgroundColor: const Color(0xFFE8DEF8), 
//       resizeToAvoidBottomInset: true,
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return Column(
//               children: [
//                 _buildAppBar(), 
//                 Expanded(
//                   child: Stack(
//                     children: [
//                       if (_currentState == CategoryState.view || 
//                           _currentState == CategoryState.calculator || 
//                           _currentState == CategoryState.deleteConfirm)
//                         Column(
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                               child: Container(
//                                 height: 40,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: TabBar(
//                                   controller: _tabController,
//                                   labelColor: Colors.white, 
//                                   unselectedLabelColor: const Color(0xFF4B5563), 
//                                   indicatorSize: TabBarIndicatorSize.tab,
//                                   indicator: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(12),
//                                     color: const Color(0xFF7F3DFF),
//                                   ),
//                                   tabs: const [
//                                     Tab(
//                                       child: Center(
//                                         child: Text("Expense", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
//                                       ),
//                                     ),
//                                     Tab(
//                                       child: Center(
//                                         child: Text("Income", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: TabBarView(
//                                 controller: _tabController,
//                                 physics: const NeverScrollableScrollPhysics(), 
//                                 children: [
//                                   _buildCategoryListFiltered(type: 'expense'),
//                                   _buildCategoryListFiltered(type: 'income'),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),

//                       if (_currentState == CategoryState.calculator) _buildCalculatorSection(screenWidth),
//                       if (_currentState == CategoryState.deleteConfirm) _buildDeleteAlertBox(screenWidth),
//                       if (_currentState == CategoryState.add) _buildAddCategoryView(constraints),
//                       if (_currentState == CategoryState.edit) _buildEditCategoryView(constraints),
//                       if (_currentState == CategoryState.calendar) _buildCalendarView(screenWidth),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // Widget _buildAppBar() {
//   //   String title = "Categories";
//   //   if (_currentState == CategoryState.add) title = "Add New Category";
//   //   if (_currentState == CategoryState.edit) title = "Edit Category";
//   //   if (_currentState == CategoryState.calendar) title = "Calendar"; 

//   //   double parsedAmount = double.tryParse(_amount) ?? 0.0;
//   //   bool hasValue = parsedAmount > 0 && _amount != "0" && _amount != "Error";
//   //   Color checkMarkColor = hasValue ? const Color(0xFF10B981) : const Color(0xFF9CA3AF);

//   //   return Padding(
//   //     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//   //     child: Row(
//   //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //       children: [
//   //         GestureDetector(
//   //           onTap: () {
//   //             if (_currentState == CategoryState.view) {
//   //               if (widget.onBackToHome != null) {
//   //                 widget.onBackToHome!(); 
//   //               }
//   //             } else if (_currentState == CategoryState.calendar) {
//   //               setState(() => _currentState = CategoryState.calculator);
//   //             } else {
//   //               setState(() => _currentState = CategoryState.view);
//   //             }
//   //           },
//   //           child: Container(
//   //             padding: const EdgeInsets.all(8),
//   //             decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
//   //             child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF1F2937)),
//   //           ),
//   //         ),
//   //         Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          
//   //         if (_currentState == CategoryState.calendar)
//   //           GestureDetector(
//   //             onTap: () async {
//   //               final DateTime? picked = await showDatePicker(
//   //                 context: context,
//   //                 initialDate: _currentSelectedCalendarDate,
//   //                 firstDate: DateTime(2020),
//   //                 lastDate: DateTime(2030),
//   //                 initialDatePickerMode: DatePickerMode.year, 
//   //                 helpText: "SELECT MONTH & YEAR",
//   //               );
//   //               if (picked != null) {
//   //                 setState(() {
//   //                   _currentSelectedCalendarDate = DateTime(picked.year, picked.month, 1);
//   //                 });
//   //               }
//   //             },
//   //             child: Container(
//   //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//   //               decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(4)),
//   //               child: Row(
//   //                 children: [
//   //                   Text(
//   //                     DateFormat('MMM/yyyy').format(_currentSelectedCalendarDate),
//   //                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
//   //                   ),
//   //                   const SizedBox(width: 2),
//   //                   const Icon(Icons.unfold_more, size: 18, color: Colors.black), 
//   //                 ],
//   //               ),
//   //             ),
//   //           )
//   //         else if (_currentState == CategoryState.calculator)
//   //           GestureDetector(
//   //             onTap: hasValue ? () => _onKeypadPressed("✓") : null, 
//   //             child: Container(
//   //               padding: const EdgeInsets.all(8),
//   //               decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
//   //               child: Icon(Icons.check, size: 18, color: checkMarkColor), 
//   //             ),
//   //           )
//   //         else
//   //           GestureDetector(
//   //             onTap: () => setState(() {
//   //               _selectedCategory = null; 
//   //               _currentState = CategoryState.view;
//   //             }),
//   //             child: Container(
//   //               padding: const EdgeInsets.all(8),
//   //               decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
//   //               child: const Icon(Icons.close, size: 16, color: Color(0xFF1F2937)),
//   //             ),
//   //           ),
//   //       ],
//   //     ),
//   //   );
//   // }
  
//   Widget _buildAppBar() {
//   String title = "Categories";
//   if (_currentState == CategoryState.add) title = "Add New Category";
//   if (_currentState == CategoryState.edit) title = "Edit Category";
//   if (_currentState == CategoryState.calendar) title = "Calendar"; 

//   double parsedAmount = double.tryParse(_amount) ?? 0.0;
//   bool hasValue = parsedAmount > 0 && _amount != "0" && _amount != "Error";
//   Color checkMarkColor = hasValue ? const Color(0xFF10B981) : const Color(0xFF9CA3AF);

//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         // 🎯 Back Arrow Button - နောက်ခံကို Rounded Rectangle ပြောင်းလဲထားပါသည်
//         GestureDetector(
//           onTap: () {
//             if (_currentState == CategoryState.view) {
//               if (widget.onBackToHome != null) {
//                 widget.onBackToHome!(); 
//               }
//             } else if (_currentState == CategoryState.calendar) {
//               setState(() => _currentState = CategoryState.calculator);
//             } else {
//               setState(() => _currentState = CategoryState.view);
//             }
//           },
//           child: Container(
//             padding: const EdgeInsets.all(10), // အချိုးကျလှပအောင် padding ထည့်ထားပါသည်
//             decoration: BoxDecoration(
//               color: Colors.white, 
//               borderRadius: BorderRadius.circular(12), // Rounded Rectangle ပုံစံ
//             ),
//             child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF1F2937)),
//           ),
//         ),
        
//         Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        
//         // 🎯 Right Action Area - Cross (x) ကို ဖြုတ်ပြီး Layout မပျက်အောင် နေရာညှိထားပါသည်
//         if (_currentState == CategoryState.calendar)
//           GestureDetector(
//             onTap: () async {
//               final DateTime? picked = await showDatePicker(
//                 context: context,
//                 initialDate: _currentSelectedCalendarDate,
//                 firstDate: DateTime(2020),
//                 lastDate: DateTime(2030),
//                 initialDatePickerMode: DatePickerMode.year, 
//                 helpText: "SELECT MONTH & YEAR",
//               );
//               if (picked != null) {
//                 setState(() {
//                   _currentSelectedCalendarDate = DateTime(picked.year, picked.month, 1);
//                 });
//               }
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(4)),
//               child: Row(
//                 children: [
//                   Text(
//                     DateFormat('MMM/yyyy').format(_currentSelectedCalendarDate),
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
//                   ),
//                   const SizedBox(width: 2),
//                   const Icon(Icons.unfold_more, size: 18, color: Colors.black), 
//                 ],
//               ),
//             ),
//           )
//         else if (_currentState == CategoryState.calculator)
//           GestureDetector(
//             onTap: hasValue ? () => _onKeypadPressed("✓") : null, 
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
//               child: Icon(Icons.check, size: 18, color: checkMarkColor), 
//             ),
//           )
//         else
//           // Cross (x) အစား ညာဘက်အစွန်းနဲ့ ဘယ်ဘက်အစွန်း Title ညီအောင် Blank Space ချန်ထားပေးပါသည်
//           const SizedBox(width: 36, height: 36),
//       ],
//     ),
//   );
// }
//   Widget _buildCategoryListFiltered({required String type}) {
//     return BlocConsumer<CategoryBloc, CategoryStateBase>(
//       listener: (context, state) {
//         if (state is CategoryError) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(state.message), backgroundColor: Colors.black),
//           );
//         }
//       },
//       builder: (context, state) {
//         if (state is CategoryLoading) {
//           return const Center(child: CircularProgressIndicator(color: Color(0xFF7F3DFF)));
//         }

//         List<CategoryItem> currentCategories = [];
//         if (state is CategoryLoaded) {
//           currentCategories = state.categories.where((c) => c.type == type).toList();
//         }

//         return ListView.builder(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           itemCount: currentCategories.length + 1,
//           itemBuilder: (context, index) {
//             if (index == currentCategories.length) {
//               return Container(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF9FAFB),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: ListTile(
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//                   leading: const Icon(Icons.add, color: Colors.black, size: 24),
//                   title: const Text("Add New Category", 
//                       style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15)),
//                   onTap: () => setState(() {
//                     _nameController.clear();
//                     _tempColor = const Color(0xFFF59E0B);
//                     _tempIcon = Icons.restaurant;
//                     _tempType = type == 'expense' ? "Expense" : "Income"; 
//                     _currentState = CategoryState.add;
//                   }),
//                 ),
//               );
//             }

//             final item = currentCategories[index];
//             return Container(
//               margin: const EdgeInsets.only(bottom: 12),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF9FAFB),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: ListTile(
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                 onTap: () => setState(() {
//                   _selectedCategory = item;
//                   _amount = "0"; _expression = ""; _shouldResetDisplay = false;
//                   _currentState = CategoryState.calculator;
//                 }),
//                 leading: Container(
//                   padding: const EdgeInsets.all(2), 
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: _selectedCategory == item 
//                         ? Border.all(color: Colors.black, width: 2) 
//                         : null,
//                   ),
//                   child: CircleAvatar(
//                     radius: 20,
//                     backgroundColor: item.color,
//                     child: Icon(item.icon, color: Colors.white, size: 20),
//                   ),
//                 ),
//                 title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 15)),
//                 trailing: IconButton(
//                   icon: const Icon(Icons.more_vert, size: 22, color: Color(0xFF9CA3AF)),
//                   onPressed: () => _showActionBottomSheet(item),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildCalculatorSection(double screenWidth) {
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Container(
//         color: const Color(0xFFF7F5FC),
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             if (_expression.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 4.0),
//                 child: Text(_expression, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
//               ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 if (_selectedCategory != null)
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(2),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(color: Colors.black, width: 1.8),
//                         ),
//                         child: CircleAvatar(
//                           radius: 16,
//                           backgroundColor: _selectedCategory!.color,
//                           child: Icon(_selectedCategory!.icon, color: Colors.white, size: 16),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         _selectedCategory!.name,
//                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
//                       ),
//                     ],
//                   )
//                 else
//                   const Icon(Icons.article_outlined, color: Color(0xFF4B5563), size: 28),

//                 Text(_amount, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
//               ],
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _noteController,
//               decoration: InputDecoration(
//                 hintText: "Note: Enter a note ......",
//                 hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14),
//                 filled: true,
//                 fillColor: const Color(0xFFF7F5FC),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(4),
//                   borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(4),
//                   borderSide: const BorderSide(color: Color(0xFF7F3DFF), width: 2),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//               ),
//             ),
//             const SizedBox(height: 12),
//             _buildBalancedKeypadUI(), 
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBalancedKeypadUI() {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         double cellHeight = 44; 

//         return GridView.count(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           crossAxisCount: 4, 
//           mainAxisSpacing: 8,
//           crossAxisSpacing: 10,
//           childAspectRatio: (constraints.maxWidth / 4) / cellHeight,
//           children: [
//             _buildBaseButton("7"), _buildBaseButton("8"), _buildBaseButton("9"), _buildActionButton("Today"),
//             _buildBaseButton("4"), _buildBaseButton("5"), _buildBaseButton("6"), 
//             Row(
//               children: [
//                 Expanded(child: _buildActionButton("+")),
//                 const SizedBox(width: 6),
//                 Expanded(child: _buildActionButton("-")),
//               ],
//             ),
//             _buildBaseButton("1"), _buildBaseButton("2"), _buildBaseButton("3"), 
//             Row(
//               children: [
//                 Expanded(child: _buildActionButton("×")),
//                 const SizedBox(width: 6),
//                 Expanded(child: _buildActionButton("÷")),
//               ],
//             ),
//             _buildBaseButton("."), _buildBaseButton("0"), _buildActionButton("⌫"), 
//             _buildActionButton("="), 
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildActionButton(String label) {
//     bool isEqual = label == "=";
//     bool isToday = label == "Today";

//     return GestureDetector(
//       onTap: () => _onKeypadPressed(label),
//       child: Container(
//         decoration: BoxDecoration(
//           color: const Color(0xFFEDE9FE),
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: Center(
//           child: Text(
//             label, 
//             style: TextStyle(
//               fontSize: isToday ? 13 : 20, 
//               fontWeight: FontWeight.w600, 
//               color: isEqual ? const Color(0xFF7F3DFF) : Colors.black,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBaseButton(String label) {
//     return GestureDetector(
//       onTap: () => _onKeypadPressed(label),
//       child: Container(
//         decoration: BoxDecoration(
//           color: const Color(0xFFEDE9FE), 
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: Center(
//           child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
//         ),
//       ),
//     );
//   }

//   Widget _buildDeleteAlertBox(double screenWidth) {
//     return Container(
//       color: Colors.black38,
//       alignment: Alignment.center,
//       child: Container(
//         width: screenWidth * 0.82,
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               "Are you sure you want to delete?",
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             const SizedBox(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 TextButton(
//                   onPressed: () => setState(() => _currentState = CategoryState.view),
//                   child: const Text("Cancel", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     if (_itemToModify != null) {
//                       BlocProvider.of<CategoryBloc>(context).add(DeleteCategoryRequested(_itemToModify!.id));
//                       BlocProvider.of<TransactionBloc>(context).add(LoadTransactions());
//                       _selectedCategory = null;
//                       _itemToModify = null;
//                       setState(() => _currentState = CategoryState.view);
//                     }
//                   },
//                   child: const Text("Confirm", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAddCategoryView(BoxConstraints constraints) {
//     return Container(
//       color: Colors.white, 
//       height: double.infinity,
//       width: double.infinity,
//       child: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildFormInputs(isDisableType: true), 
//               const SizedBox(height: 24),
//               const Text("Choose Colour", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
//               const SizedBox(height: 14),
//               _buildColorPicker(),
//               const SizedBox(height: 28),
//               const Text("Choose Icon", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
//               const SizedBox(height: 14),
              
//               _buildIconGrid(constraints),
              
//               const SizedBox(height: 32), 
              
//               _buildSaveButton(
//                 label: "Save",
//                 onPressed: () {
//                   if (_nameController.text.isNotEmpty) {
//                     BlocProvider.of<CategoryBloc>(context).add(
//                       AddCategoryRequested(
//                         name: _nameController.text.trim(),
//                         icon: _tempIcon,
//                         color: _tempColor,
//                         type: _tempType.toLowerCase(),
//                       ),
//                     );
//                     setState(() => _currentState = CategoryState.view);
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEditCategoryView(BoxConstraints constraints) {
//     return Container(
//       color: Colors.white, 
//       height: double.infinity,
//       width: double.infinity,
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildFormInputs(isDisableType: true), 
//           const SizedBox(height: 24),
//           const Text("Choose Colour", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
//           const SizedBox(height: 14),
//           _buildColorPicker(),
//           const Spacer(),
//           // ပြင်ဆင်ပြီးသား ကုဒ်အပိုင်း
// Row(
//   children: [
//     Expanded(
//       child: SizedBox(
//         height: 48,
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF7F3DFF), // ခရမ်းရောင်နောက်ခံ
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             elevation: 0,
//           ),
//           onPressed: () => setState(() => _currentState = CategoryState.view),
//           child: const Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
//         ),
//       ),
//     ),
//     const SizedBox(width: 16),
//     Expanded(
//       child: _buildSaveButton(
//         label: "Done",
//         onPressed: () {
//           if (_nameController.text.isNotEmpty && _itemToModify != null) {
//             BlocProvider.of<CategoryBloc>(context).add(
//               UpdateCategoryRequested(
//                 id: _itemToModify!.id,
//                 name: _nameController.text.trim(),
//                 icon: _tempIcon,
//                 color: _tempColor,
//                 type: _tempType.toLowerCase(),
//               ),
//             );
//             _nameController.clear();
//             _itemToModify = null;
//             setState(() => _currentState = CategoryState.view);
//           }
//         },
//       ),
//     ),
//   ],
// ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCalendarView(double screenWidth) {
//     final List<String> weekdays = ["S", "M", "T", "W", "T", "F", "S"];
    
//     final DateTime now = _currentSelectedCalendarDate;
//     final int year = now.year;
//     final int month = now.month;

//     final DateTime firstDayOfMonth = DateTime(year, month, 1);
//     final int daysInMonth = DateTime(year, month + 1, 0).day;
//     final int firstWeekdayIndex = firstDayOfMonth.weekday % 7; 
//     final int daysInPrevMonth = DateTime(year, month, 0).day;

//     final List<Map<String, dynamic>> calendarDays = [];

//     for (int i = firstWeekdayIndex - 1; i >= 0; i--) {
//       calendarDays.add({
//         "day": daysInPrevMonth - i,
//         "isCurrentMonth": false,
//         "date": DateTime(year, month - 1, daysInPrevMonth - i)
//       });
//     }

//     for (int i = 1; i <= daysInMonth; i++) {
//       calendarDays.add({
//         "day": i,
//         "isCurrentMonth": true,
//         "date": DateTime(year, month, i)
//       });
//     }

//     int totalSlots = 42; 
//     int nextMonthDay = 1;
//     while (calendarDays.length < totalSlots) {
//       calendarDays.add({
//         "day": nextMonthDay,
//         "isCurrentMonth": false,
//         "date": DateTime(year, month + 1, nextMonthDay)
//       });
//       nextMonthDay++;
//     }

//     return Container(
//       color: Colors.white, 
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         children: [
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: weekdays.map((w) => SizedBox(
//               width: screenWidth / 8,
//               child: Text(
//                 w, 
//                 textAlign: TextAlign.center, 
//                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)
//               ),
//             )).toList(),
//           ),
//           const SizedBox(height: 16),
//           Expanded(
//             child: GridView.builder(
//               itemCount: calendarDays.length,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 7, 
//                 mainAxisSpacing: 14, 
//                 crossAxisSpacing: 10,
//               ),
//               itemBuilder: (context, index) {
//                 final dayData = calendarDays[index];
//                 final int dayNumber = dayData["day"];
//                 final bool isCurrentMonth = dayData["isCurrentMonth"];
//                 final DateTime cellDate = dayData["date"];

//                 bool isSelectedDay = isCurrentMonth && 
//                     (cellDate.day == _currentSelectedCalendarDate.day) &&
//                     (cellDate.month == _currentSelectedCalendarDate.month) &&
//                     (cellDate.year == _currentSelectedCalendarDate.year);

//                 return GestureDetector(
//                   key: ValueKey(cellDate.toString()), 
//                   onTap: () {
//                     setState(() {
//                       _currentSelectedCalendarDate = cellDate;
//                       _calendarHeaderText = DateFormat('EEE, MMM d, yyyy').format(_currentSelectedCalendarDate);
//                       _currentState = CategoryState.calculator; 
//                     });
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: isSelectedDay ? const Color(0xFF7F3DFF) : Colors.transparent,
//                       shape: BoxShape.circle,
//                     ),
//                     alignment: Alignment.center,
//                     child: Text(
//                       dayNumber.toString(),
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: isSelectedDay ? FontWeight.bold : FontWeight.w600,
//                         color: isSelectedDay 
//                             ? Colors.white 
//                             : (isCurrentMonth ? Colors.black : const Color(0xFF9CA3AF)),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFormInputs({bool isDisableType = false}) {
//     return Column(
//       children: [
//         ListTile(
//   contentPadding: EdgeInsets.zero,
//   title: const Text("Icon", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
//   trailing: CircleAvatar(
//     backgroundColor: _tempColor, 
//     radius: 24, 
//     child: Icon(_tempIcon, color: Colors.white, size: 24)
//   ), 
// ),
//         const SizedBox(height: 10),
//         ListTile(
//           contentPadding: EdgeInsets.zero,
//           title: const Text("Name", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
//           trailing: SizedBox(
//             width: 180,
//             child: TextField(
//               controller: _nameController,
//               textAlign: TextAlign.end,
//               style: const TextStyle(fontSize: 15, color: Colors.black),
//               decoration: const InputDecoration(
//                 hintText: "Enter category name...",
//                 border: InputBorder.none,
//                 suffixIcon: Icon(Icons.edit, size: 16, color: Color(0xFF9CA3AF)),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//         ListTile(
//           contentPadding: EdgeInsets.zero,
//           title: const Text("Type", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
//           trailing: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12.0),
//             child: Text(_tempType, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 16)),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildColorPicker() {
//     return SizedBox(
//       height: 46,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: _availableColors.length,
//         itemBuilder: (context, index) {
//           final color = _availableColors[index];
//           bool isSelected = _tempColor == color;
//           return GestureDetector(
//             onTap: () => setState(() => _tempColor = color),
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 6),
//               width: 40,
//               decoration: BoxDecoration(
//                 color: color,
//                 shape: BoxShape.circle,
//                 border: isSelected ? Border.all(color: const Color(0xFFF472B6), width: 3) : null,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildIconGrid(BoxConstraints constraints) {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 5, mainAxisSpacing: 16, crossAxisSpacing: 16
//       ),
//       itemCount: _availableIcons.length,
//       itemBuilder: (context, index) {
//         final icon = _availableIcons[index];
//         bool isSelected = _tempIcon == icon;
//         return GestureDetector(
//           onTap: () => setState(() => _tempIcon = icon),
//           child: CircleAvatar(
//             backgroundColor: isSelected ? const Color(0xFFFCE7F3) : const Color(0xFFE5E7EB),
//             child: Icon(icon, color: isSelected ? const Color(0xFFEC4899) : const Color(0xFF6B7280)),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildSaveButton({required String label, required VoidCallback onPressed}) {
//     return SizedBox(
//       width: double.infinity,
//       height: 48,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF7F3DFF),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           elevation: 0,
//         ),
//         onPressed: onPressed,
//         child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
//       ),
//     );
//   }
// }

import 'package:expense_tracker/features/auth/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/category_state.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/transaction_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/transaction_event.dart';
import 'package:expense_tracker/models/category_model.dart';
import 'package:expense_tracker/models/record_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

List<RecordItem> globalRecords = [];
enum CategoryState { view, calculator, deleteConfirm, add, edit, calendar }

class CategoryScreen extends StatefulWidget {
  final VoidCallback? onBackToHome; 
  final ValueChanged<bool>? onToggleNavBar; // 🎯 Nav Bar ထိန်းချုပ်ရန် Callback အသစ်

  const CategoryScreen({Key? key, this.onBackToHome, this.onToggleNavBar}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with SingleTickerProviderStateMixin {
  CategoryState _currentState = CategoryState.view;
  int _currentTabIndex = 2;
  
  late TabController _tabController;

  String _amount = "0";             
  String _expression = "";          
  bool _shouldResetDisplay = false; 

  final List<Color> _availableColors = [
    const Color(0xFF6366F1), const Color(0xFF10B981), const Color(0xFFF59E0B),
    const Color(0xFFEF4444), const Color(0xFFEC4899), const Color(0xFF06B6D4),
    const Color(0xFF8B5CF6), const Color(0xFF14B8A6), const Color(0xFFF43F5E),
    const Color(0xFF84CC16), const Color(0xFF3B82F6), const Color(0xFFEAB308),
    const Color(0xFF6B7280), const Color(0xFF9A3412), const Color(0xFFF3ED5A),
  ];

  final List<IconData> _availableIcons = [
    Icons.restaurant, Icons.shopping_bag, Icons.directions_car, Icons.home,
    Icons.local_hospital, Icons.school, Icons.flight, Icons.movie,
    Icons.fitness_center, Icons.dry_cleaning, Icons.pets, Icons.wifi,
    Icons.build, Icons.card_giftcard, Icons.attach_money, Icons.payments,
    Icons.trending_up, Icons.storefront, Icons.account_balance, Icons.calendar_month_outlined,    
    Icons.handshake, Icons.phone, Icons.school_outlined, Icons.music_note_outlined,
    Icons.headphones, Icons.local_cafe, Icons.health_and_safety, Icons.computer,
  ];

  CategoryItem? _selectedCategory;
  CategoryItem? _itemToModify;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  
  Color _tempColor = const Color(0xFFF59E0B);
  IconData _tempIcon = Icons.restaurant;
  String _tempType = "Expense"; 
  
  String _calendarHeaderText = "";
  DateTime _currentSelectedCalendarDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _calendarHeaderText = DateFormat('EEE, MMM d, yyyy').format(DateTime.now());
    _tabController = TabController(length: 2, vsync: this);
    
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    
    BlocProvider.of<CategoryBloc>(context).add(LoadCategories());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // 🎯 ပြည်တွင်း State ရော Parent Nav Bar ပါ တစ်ခါတည်း ချိန်ညှိပေးမယ့် Function
  void _updateState(CategoryState newState) {
    setState(() {
      _currentState = newState;
    });
    if (widget.onToggleNavBar != null) {
      widget.onToggleNavBar!(newState == CategoryState.view);
    }
  }

  void _onKeypadPressed(String value) {
    if (value == "Today") {
      _currentSelectedCalendarDate = DateTime.now();
      _calendarHeaderText = DateFormat('EEE, MMM d, yyyy').format(_currentSelectedCalendarDate);
      _updateState(CategoryState.calendar); 
      return;
    }

    setState(() {
      if (value == "⌫") {
        if (_amount != "0" && _amount != "Error") {
          if (_amount.length > 1) {
            _amount = _amount.substring(0, _amount.length - 1);
          } else {
            _amount = "0";
          }
        }
        return;
      }

      if (value == "+" || value == "-" || value == "×" || value == "÷") {
        if (_amount == "Error") return;
        
        if (_expression.contains("=")) {
          _expression = "${_amount} ${value}";
        } else {
          _expression = _expression.isEmpty ? "${_amount} ${value}" : "${_expression} ${_amount} ${value}";
        }
        
        _shouldResetDisplay = true; 
        return;
      }

      if (value == "=") {
        if (_expression.isNotEmpty && !_expression.contains("=")) {
          String fullExpression = "$_expression $_amount";
          _calculateAdvancedResult(fullExpression);
        }
        return;
      }

      if (value == "✓") {
        double parsedAmount = double.tryParse(_amount) ?? 0.0;
        if (parsedAmount == 0.0 || _amount == "0" || _amount == "Error") return;

        if (_selectedCategory != null) {
          String userNote = _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : "No note";
          
          BlocProvider.of<TransactionBloc>(context).add(
            AddTransactionRequested(
              categoryId: _selectedCategory!.id,
              amount: parsedAmount,
              note: userNote,
            ),
          );
          BlocProvider.of<TransactionBloc>(context).add(LoadTransactions());
          BlocProvider.of<CategoryBloc>(context).add(LoadCategories()); 
        }
        
        _amount = "0"; _expression = ""; _shouldResetDisplay = false;
        _noteController.clear(); _selectedCategory = null;
        _updateState(CategoryState.view);
        return;
      }

      if (value == ".") {
        if (_shouldResetDisplay || _amount == "Error") {
          _amount = "0."; _shouldResetDisplay = false;
        } else if (!_amount.contains(".")) {
          _amount += ".";
        }
        return;
      }

      if (_shouldResetDisplay || _amount == "Error") {
        _amount = value; _shouldResetDisplay = false;
      } else {
        if (_amount == "0") {
          _amount = value; 
        } else {
          _amount += value; 
        }
      }
    });
  }

  void _calculateAdvancedResult(String expr) {
    try {
      List<String> tokens = expr.split(" ");
      List<double> numbers = [];
      List<String> operators = [];

      for (var token in tokens) {
        if (token == "+" || token == "-" || token == "×" || token == "÷") {
          operators.add(token);
        } else {
          numbers.add(double.tryParse(token) ?? 0.0);
        }
      }

      if (numbers.length != operators.length + 1) {
        _amount = "Error"; _expression = ""; return;
      }

      for (int i = 0; i < operators.length; ) {
        if (operators[i] == "×" || operators[i] == "÷") {
          double num1 = numbers[i];
          double num2 = numbers[i + 1];
          double res = 0;

          if (operators[i] == "×") {
            res = num1 * num2;
          } else {
            if (num2 == 0) {
              _amount = "Error"; _expression = ""; return;
            }
            res = num1 / num2;
          }

          numbers[i] = res;
          numbers.removeAt(i + 1);
          operators.removeAt(i);
        } else {
          i++;
        }
      }

      double finalResult = numbers[0];
      for (int i = 0; i < operators.length; i++) {
        double nextNum = numbers[i + 1];
        if (operators[i] == "+") {
          finalResult += nextNum;
        } else if (operators[i] == "-") {
          finalResult -= nextNum;
        }
      }

      setState(() {
        if (finalResult % 1 == 0) {
          _amount = finalResult.toInt().toString();
        } else {
          _amount = finalResult.toStringAsFixed(2);
        }
        _expression = "$expr = $_amount";
        _shouldResetDisplay = true;
      });
    } catch (e) {
      _amount = "Error";
      _expression = "";
    }
  }

  void _showActionBottomSheet(CategoryItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: const BoxDecoration(
          color: Color(0xFFF7F5FC),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Color(0xFF6366F1)),
                title: const Text('Edit Category', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1F2937))),
                onTap: () {
                  Navigator.pop(context);
                  _nameController.text = item.name;
                  _tempColor = item.color;
                  _tempIcon = item.icon;
                  _tempType = item.type == 'expense' ? "Expense" : "Income";
                  _itemToModify = item;
                  _updateState(CategoryState.edit);
                },
              ),
              const Divider(color: Color(0xFFE5E7EB), height: 1),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Color(0xFFF87171)),
                title: const Text('Delete Category', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1F2937))),
                onTap: () {
                  Navigator.pop(context);
                  _itemToModify = item;
                  _updateState(CategoryState.deleteConfirm);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFE8DEF8), 
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                _buildAppBar(), 
                Expanded(
                  child: Stack(
                    children: [
                      if (_currentState == CategoryState.view || 
                          _currentState == CategoryState.calculator || 
                          _currentState == CategoryState.deleteConfirm)
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  labelColor: Colors.white, 
                                  unselectedLabelColor: const Color(0xFF4B5563), 
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  indicator: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xFF7F3DFF),
                                  ),
                                  tabs: const [
                                    Tab(
                                      child: Center(
                                        child: Text("Expense", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                      ),
                                    ),
                                    Tab(
                                      child: Center(
                                        child: Text("Income", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                physics: const NeverScrollableScrollPhysics(), 
                                children: [
                                  _buildCategoryListFiltered(type: 'expense'),
                                  _buildCategoryListFiltered(type: 'income'),
                                ],
                              ),
                            ),
                          ],
                        ),

                      if (_currentState == CategoryState.calculator) _buildCalculatorSection(screenWidth),
                      if (_currentState == CategoryState.deleteConfirm) _buildDeleteAlertBox(screenWidth),
                      if (_currentState == CategoryState.add) _buildAddCategoryView(constraints),
                      if (_currentState == CategoryState.edit) _buildEditCategoryView(constraints),
                      if (_currentState == CategoryState.calendar) _buildCalendarView(screenWidth),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    String title = "Categories";
    if (_currentState == CategoryState.add) title = "Add New Category";
    if (_currentState == CategoryState.edit) title = "Edit Category";
    if (_currentState == CategoryState.calendar) title = "Calendar"; 

    double parsedAmount = double.tryParse(_amount) ?? 0.0;
    bool hasValue = parsedAmount > 0 && _amount != "0" && _amount != "Error";
    Color checkMarkColor = hasValue ? const Color(0xFF10B981) : const Color(0xFF9CA3AF);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (_currentState == CategoryState.view) {
                if (widget.onBackToHome != null) {
                  widget.onBackToHome!(); 
                }
              } else if (_currentState == CategoryState.calendar) {
                _updateState(CategoryState.calculator);
              } else {
                _updateState(CategoryState.view);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF1F2937)),
            ),
          ),
          
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          
          if (_currentState == CategoryState.calendar)
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _currentSelectedCalendarDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  initialDatePickerMode: DatePickerMode.year, 
                  helpText: "SELECT MONTH & YEAR",
                );
                if (picked != null) {
                  setState(() {
                    _currentSelectedCalendarDate = DateTime(picked.year, picked.month, 1);
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(4)),
                child: Row(
                  children: [
                    Text(
                      DateFormat('MMM/yyyy').format(_currentSelectedCalendarDate),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.unfold_more, size: 18, color: Colors.black), 
                  ],
                ),
              ),
            )
          else if (_currentState == CategoryState.calculator)
            GestureDetector(
              onTap: hasValue ? () => _onKeypadPressed("✓") : null, 
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.check, size: 18, color: checkMarkColor), 
              ),
            )
          else
            const SizedBox(width: 36, height: 36), 
        ],
      ),
    );
  }
  
  Widget _buildCategoryListFiltered({required String type}) {
    return BlocConsumer<CategoryBloc, CategoryStateBase>(
      listener: (context, state) {
        if (state is CategoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.black),
          );
        }
      },
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF7F3DFF)));
        }

        List<CategoryItem> currentCategories = [];
        if (state is CategoryLoaded) {
          currentCategories = state.categories.where((c) => c.type == type).toList();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: currentCategories.length + 1,
          itemBuilder: (context, index) {
            if (index == currentCategories.length) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  leading: const Icon(Icons.add, color: Colors.black, size: 24),
                  title: const Text("Add New Category", 
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15)),
                  onTap: () {
                    _nameController.clear();
                    _tempColor = const Color(0xFFF59E0B);
                    _tempIcon = Icons.restaurant;
                    _tempType = type == 'expense' ? "Expense" : "Income"; 
                    _updateState(CategoryState.add);
                  },
                ),
              );
            }

            final item = currentCategories[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                onTap: () {
                  _selectedCategory = item;
                  _amount = "0"; _expression = ""; _shouldResetDisplay = false;
                  _updateState(CategoryState.calculator);
                },
                leading: Container(
                  padding: const EdgeInsets.all(2), 
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: _selectedCategory == item 
                        ? Border.all(color: Colors.black, width: 2) 
                        : null,
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: item.color,
                    child: Icon(item.icon, color: Colors.white, size: 20),
                  ),
                ),
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 15)),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert, size: 22, color: Color(0xFF9CA3AF)),
                  onPressed: () => _showActionBottomSheet(item),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCalculatorSection(double screenWidth) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: const Color(0xFFF7F5FC),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_expression.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(_expression, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_selectedCategory != null)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 1.8),
                        ),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: _selectedCategory!.color,
                          child: Icon(_selectedCategory!.icon, color: Colors.white, size: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedCategory!.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  )
                else
                  const Icon(Icons.article_outlined, color: Color(0xFF4B5563), size: 28),

                Text(_amount, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: "Note: Enter a note ......",
                hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF7F5FC),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFF7F3DFF), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),
            _buildBalancedKeypadUI(), 
          ],
        ),
      ),
    );
  }

  Widget _buildBalancedKeypadUI() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cellHeight = 44; 

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4, 
          mainAxisSpacing: 8,
          crossAxisSpacing: 10,
          childAspectRatio: (constraints.maxWidth / 4) / cellHeight,
          children: [
            _buildBaseButton("7"), _buildBaseButton("8"), _buildBaseButton("9"), _buildActionButton("Today"),
            _buildBaseButton("4"), _buildBaseButton("5"), _buildBaseButton("6"), 
            Row(
              children: [
                Expanded(child: _buildActionButton("+")),
                const SizedBox(width: 6),
                Expanded(child: _buildActionButton("-")),
              ],
            ),
            _buildBaseButton("1"), _buildBaseButton("2"), _buildBaseButton("3"), 
            Row(
              children: [
                Expanded(child: _buildActionButton("×")),
                const SizedBox(width: 6),
                Expanded(child: _buildActionButton("÷")),
              ],
            ),
            _buildBaseButton("."), _buildBaseButton("0"), _buildActionButton("⌫"), 
            _buildActionButton("="), 
          ],
        );
      },
    );
  }

  Widget _buildActionButton(String label) {
    bool isEqual = label == "=";
    bool isToday = label == "Today";

    return GestureDetector(
      onTap: () => _onKeypadPressed(label),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEDE9FE),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            label, 
            style: TextStyle(
              fontSize: isToday ? 13 : 20, 
              fontWeight: FontWeight.w600, 
              color: isEqual ? const Color(0xFF7F3DFF) : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBaseButton(String label) {
    return GestureDetector(
      onTap: () => _onKeypadPressed(label),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEDE9FE), 
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
        ),
      ),
    );
  }

  Widget _buildDeleteAlertBox(double screenWidth) {
    return Container(
      color: Colors.black38,
      alignment: Alignment.center,
      child: Container(
        width: screenWidth * 0.82,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Are you sure you want to delete?",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => _updateState(CategoryState.view),
                  child: const Text("Cancel", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                TextButton(
                  onPressed: () {
                    if (_itemToModify != null) {
                      BlocProvider.of<CategoryBloc>(context).add(DeleteCategoryRequested(_itemToModify!.id));
                      BlocProvider.of<TransactionBloc>(context).add(LoadTransactions());
                      _selectedCategory = null;
                      _itemToModify = null;
                      _updateState(CategoryState.view);
                    }
                  },
                  child: const Text("Confirm", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAddCategoryView(BoxConstraints constraints) {
    return Container(
      color: Colors.white, 
      height: double.infinity,
      width: double.infinity,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormInputs(isDisableType: true), 
              const SizedBox(height: 24),
              const Text("Choose Colour", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 14),
              _buildColorPicker(),
              const SizedBox(height: 28),
              const Text("Choose Icon", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 14),
              
              _buildIconGrid(constraints),
              
              const SizedBox(height: 32), 
              
              _buildSaveButton(
                label: "Save",
                onPressed: () {
                  if (_nameController.text.isNotEmpty) {
                    BlocProvider.of<CategoryBloc>(context).add(
                      AddCategoryRequested(
                        name: _nameController.text.trim(),
                        icon: _tempIcon,
                        color: _tempColor,
                        type: _tempType.toLowerCase(),
                      ),
                    );
                    _updateState(CategoryState.view);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditCategoryView(BoxConstraints constraints) {
    return Container(
      color: Colors.white, 
      height: double.infinity,
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormInputs(isDisableType: true), 
          const SizedBox(height: 24),
          const Text("Choose Colour", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 14),
          _buildColorPicker(),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7F3DFF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () => _updateState(CategoryState.view),
                    child: const Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSaveButton(
                  label: "Done",
                  onPressed: () {
                    if (_nameController.text.isNotEmpty && _itemToModify != null) {
                      BlocProvider.of<CategoryBloc>(context).add(
                        UpdateCategoryRequested(
                          id: _itemToModify!.id,
                          name: _nameController.text.trim(),
                          icon: _tempIcon,
                          color: _tempColor,
                          type: _tempType.toLowerCase(),
                        ),
                      );
                      _nameController.clear();
                      _itemToModify = null;
                      _updateState(CategoryState.view);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView(double screenWidth) {
    final List<String> weekdays = ["S", "M", "T", "W", "T", "F", "S"];
    
    final DateTime now = _currentSelectedCalendarDate;
    final int year = now.year;
    final int month = now.month;

    final DateTime firstDayOfMonth = DateTime(year, month, 1);
    final int daysInMonth = DateTime(year, month + 1, 0).day;
    final int firstWeekdayIndex = firstDayOfMonth.weekday % 7; 
    final int daysInPrevMonth = DateTime(year, month, 0).day;

    final List<Map<String, dynamic>> calendarDays = [];

    for (int i = firstWeekdayIndex - 1; i >= 0; i--) {
      calendarDays.add({
        "day": daysInPrevMonth - i,
        "isCurrentMonth": false,
        "date": DateTime(year, month - 1, daysInPrevMonth - i)
      });
    }

    for (int i = 1; i <= daysInMonth; i++) {
      calendarDays.add({
        "day": i,
        "isCurrentMonth": true,
        "date": DateTime(year, month, i)
      });
    }

    int totalSlots = 42; 
    int nextMonthDay = 1;
    while (calendarDays.length < totalSlots) {
      calendarDays.add({
        "day": nextMonthDay,
        "isCurrentMonth": false,
        "date": DateTime(year, month + 1, nextMonthDay)
      });
      nextMonthDay++;
    }

    return Container(
      color: Colors.white, 
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays.map((w) => SizedBox(
              width: screenWidth / 8,
              child: Text(
                w, 
                textAlign: TextAlign.center, 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              itemCount: calendarDays.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, 
                mainAxisSpacing: 14, 
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final dayData = calendarDays[index];
                final int dayNumber = dayData["day"];
                final bool isCurrentMonth = dayData["isCurrentMonth"];
                final DateTime cellDate = dayData["date"];

                bool isSelectedDay = isCurrentMonth && 
                    (cellDate.day == _currentSelectedCalendarDate.day) &&
                    (cellDate.month == _currentSelectedCalendarDate.month) &&
                    (cellDate.year == _currentSelectedCalendarDate.year);

                return GestureDetector(
                  key: ValueKey(cellDate.toString()), 
                  onTap: () {
                    _currentSelectedCalendarDate = cellDate;
                    _calendarHeaderText = DateFormat('EEE, MMM d, yyyy').format(_currentSelectedCalendarDate);
                    _updateState(CategoryState.calculator); 
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelectedDay ? const Color(0xFF7F3DFF) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      dayNumber.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelectedDay ? FontWeight.bold : FontWeight.w600,
                        color: isSelectedDay 
                            ? Colors.white 
                            : (isCurrentMonth ? Colors.black : const Color(0xFF9CA3AF)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormInputs({bool isDisableType = false}) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Icon", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
          trailing: CircleAvatar(
            backgroundColor: _tempColor, 
            radius: 24, 
            child: Icon(_tempIcon, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(height: 10),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Name", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
          trailing: SizedBox(
            width: 180,
            child: TextField(
              controller: _nameController,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 15, color: Colors.black),
              decoration: const InputDecoration(
                hintText: "Enter category name...",
                border: InputBorder.none,
                suffixIcon: Icon(Icons.edit, size: 16, color: Color(0xFF9CA3AF)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Type", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
          trailing: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(_tempType, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPicker() {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _availableColors.length,
        itemBuilder: (context, index) {
          final color = _availableColors[index];
          bool isSelected = _tempColor == color;
          return GestureDetector(
            onTap: () => setState(() => _tempColor = color),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected ? Border.all(color: const Color(0xFFF472B6), width: 3) : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconGrid(BoxConstraints constraints) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, mainAxisSpacing: 16, crossAxisSpacing: 16
      ),
      itemCount: _availableIcons.length,
      itemBuilder: (context, index) {
        final icon = _availableIcons[index];
        bool isSelected = _tempIcon == icon;
        return GestureDetector(
          onTap: () => setState(() => _tempIcon = icon),
          child: CircleAvatar(
            backgroundColor: isSelected ? const Color(0xFFFCE7F3) : const Color(0xFFE5E7EB),
            child: Icon(icon, color: isSelected ? const Color(0xFFEC4899) : const Color(0xFF6B7280)),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7F3DFF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}