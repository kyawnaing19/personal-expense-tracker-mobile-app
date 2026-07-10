import 'package:expense_tracker/features/auth/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/category_state.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/transaction_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/transaction_event.dart';
import 'package:expense_tracker/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'category_states.dart';
import 'category_calculator_view.dart';
import 'category_forms_view.dart';

class CategoryScreen extends StatefulWidget {
  final VoidCallback? onBackToHome; 
  final Function(CategoryState)? onStateChanged;

  const CategoryScreen({Key? key, this.onBackToHome, this.onStateChanged}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with SingleTickerProviderStateMixin {
  CategoryState _currentState = CategoryState.view;
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
  
  DateTime _currentSelectedCalendarDate = DateTime.now();

  void _updateState(CategoryState newState) {
    setState(() {
      _currentState = newState;
    });
    if (widget.onStateChanged != null) {
      widget.onStateChanged!(newState); 
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
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

  void _onKeypadPressed(String value) {
    if (value == "Today") {
      setState(() {
        _currentSelectedCalendarDate = DateTime.now();
      });
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
          _calculateAdvancedResult("$_expression $_amount");
        }
        return;
      }

      if (value == "✓") {
        double parsedAmount = double.tryParse(_amount) ?? 0.0;
        if (parsedAmount == 0.0 || _amount == "0" || _amount == "Error") return;

        if (_selectedCategory != null) {
          String userNote = _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : "No note";
          BlocProvider.of<TransactionBloc>(context).add(
            AddTransactionRequested(categoryId: _selectedCategory!.id, amount: parsedAmount, note: userNote),
          );
          // LoadTransactions() / LoadCategories() ကို ဒီနေရာမှာ ထပ်မခေါ်တော့ပါ --
          // TransactionBloc က AddTransactionRequested အောင်မြင်ရင် TransactionActionSuccess
          // ကို emit လုပ်ပြီးသားမို့ RecordHistoryScreen ရဲ့ listener က transaction list ကို
          // အလိုအလျောက် ပြန် load လုပ်ပေးမှာပါ။ Category data ကတော့ ဒီနေရာမှာ
          // လုံးဝ မပြောင်းလဲသွားလို့ ပြန် fetch လုပ်စရာ မလိုပါ။
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
        _amount = (_amount == "0") ? value : _amount + value;
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

      for (int i = 0; i < operators.length; ) {
        if (operators[i] == "×" || operators[i] == "÷") {
          double num1 = numbers[i];
          double num2 = numbers[i + 1];
          if (operators[i] == "÷" && num2 == 0) { _amount = "Error"; _expression = ""; return; }
          numbers[i] = (operators[i] == "×") ? num1 * num2 : num1 / num2;
          numbers.removeAt(i + 1);
          operators.removeAt(i);
        } else {
          i++;
        }
      }

      double finalResult = numbers[0];
      for (int i = 0; i < operators.length; i++) {
        if (operators[i] == "+") finalResult += numbers[i + 1];
        if (operators[i] == "-") finalResult -= numbers[i + 1];
      }

      setState(() {
        _amount = finalResult % 1 == 0 ? finalResult.toInt().toString() : finalResult.toStringAsFixed(2);
        _expression = "$expr = $_amount";
        _shouldResetDisplay = true;
      });
    } catch (e) {
      _amount = "Error"; _expression = "";
    }
  }

  void _showActionBottomSheet(CategoryItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
        child: Material(
          color: const Color(0xFFF7F5FC),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_outlined, color: Color(0xFF6366F1)),
                    title: const Text('Edit Category'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _nameController.text = item.name;
                        _tempColor = item.color;
                        _tempIcon = item.icon;
                        _tempType = item.type == 'expense' ? "Expense" : "Income";
                        _itemToModify = item;
                      });
                      _updateState(CategoryState.edit);
                    },
                  ),
                  const Divider(color: Color(0xFFE5E7EB), height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Color(0xFFF87171)),
                    title: const Text('Delete Category'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() { _itemToModify = item; });
                      _updateState(CategoryState.deleteConfirm);
                    },
                  ),
                ],
              ),
            ),
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
                _buildAppBar(), // Top Nav Bar ကို အမြဲတမ်း အပေါ်ဆုံးမှာ ထားပါမည် 🎯
                Expanded(
                  child: Stack(
                    children: [
                      // 1️⃣ ပုံမှန် View အခြေအနေ (Category List ပြသရန်)
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: Container(
  height: 45, // သင်လိုချင်တဲ့ အမြင့်အတိုင်း
  decoration: BoxDecoration(
    color: Colors.white, // Tab မသွားတဲ့နေရာတွေအတွက် အဖြူရောင် background
    borderRadius: BorderRadius.circular(12),
  ),
  child: TabBar(
    controller: _tabController,
    labelColor: Colors.white, // ရွေးထားတဲ့ Tab (ခရမ်းရောင်) ပေါ်က စာအရောင်
    unselectedLabelColor: const Color(0xFF4B5563), // မရွေးထားတဲ့ Tab စာအရောင်
    dividerColor: Colors.transparent, // divider ပျောက်စေရန်
    indicatorSize: TabBarIndicatorSize.tab,
    indicator: BoxDecoration(
      borderRadius: BorderRadius.circular(8), // ပိုလှအောင် နည်းနည်းညှိပေးပါ
      color: const Color(0xFF7F3DFF), // ရွေးထားတဲ့ Tab ရဲ့ ခရမ်းရောင်
    ),
    tabs: const [
      Tab(child: Center(child: Text("Expense", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)))),
      Tab(child: Center(child: Text("Income", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)))),
    ],
  ),
),
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              physics: const NeverScrollableScrollPhysics(), 
                              children: [ _buildCategoryListFiltered('expense'), _buildCategoryListFiltered('income') ],
                            ),
                          ),
                        ],
                      ),

                      // 2️⃣ Calculator ပွင့်လာသည့် View
                      if (_currentState == CategoryState.calculator)
                        CategoryCalculatorView(
                          selectedCategory: _selectedCategory,
                          amount: _amount,
                          expression: _expression,
                          noteController: _noteController,
                          onKeypadPressed: _onKeypadPressed,
                        ),

                      // 3️⃣ Add Category View
                      if (_currentState == CategoryState.add)
                        CategoryFormsView.buildAddCategoryView(
                          constraints: constraints,
                          nameController: _nameController,
                          tempColor: _tempColor,
                          tempIcon: _tempIcon,
                          tempType: _tempType,
                          availableColors: _availableColors,
                          availableIcons: _availableIcons,
                          onColorSelected: (c) => setState(() => _tempColor = c),
                          onIconSelected: (i) => setState(() => _tempIcon = i),
                          onSave: () {
                            if (_nameController.text.isNotEmpty) {
                              BlocProvider.of<CategoryBloc>(context).add(AddCategoryRequested(name: _nameController.text.trim(), icon: _tempIcon, color: _tempColor, type: _tempType.toLowerCase()));
                              _updateState(CategoryState.view);
                            }
                          },
                        ),

                      // 4️⃣ Edit Category View (Icon မရွေးစေဘဲ ပြင်ဆင်ပြီး 🎯)
                      if (_currentState == CategoryState.edit)
                        CategoryFormsView.buildEditCategoryView(
                          constraints: constraints,
                          nameController: _nameController,
                          tempColor: _tempColor,
                          tempIcon: _tempIcon,
                          tempType: _tempType,
                          availableColors: _availableColors,
                          onColorSelected: (c) => setState(() => _tempColor = c),
                          onCancel: () => _updateState(CategoryState.view),
                          onDone: () {
                            if (_nameController.text.isNotEmpty && _itemToModify != null) {
                              BlocProvider.of<CategoryBloc>(context).add(UpdateCategoryRequested(id: _itemToModify!.id, name: _nameController.text.trim(), icon: _tempIcon, color: _tempColor, type: _tempType.toLowerCase()));
                              _nameController.clear(); _itemToModify = null;
                              _updateState(CategoryState.view);
                            }
                          },
                        ),

                      // 5️⃣ Calendar View
                      if (_currentState == CategoryState.calendar)
                        CategoryFormsView.buildCalendarView(
                          screenWidth: screenWidth,
                          currentSelectedCalendarDate: _currentSelectedCalendarDate,
                          onDateSelected: (date) {
                            setState(() {
                              _currentSelectedCalendarDate = date;
                            });
                            _updateState(CategoryState.calculator);
                          },
                        ),

                      // 6️⃣ Delete Confirmation
                      if (_currentState == CategoryState.deleteConfirm) _buildDeleteAlertBox(screenWidth),
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
            //   if (_currentState == CategoryState.view) {
            //     if (widget.onBackToHome != null) widget.onBackToHome!();

            //   } 
              
            //   else if (_currentState == CategoryState.calendar) {
            //     _updateState(CategoryState.calculator);
            //   } else {
            //     _updateState(CategoryState.view);
            //   }
            // },
            if (_currentState == CategoryState.view) {
      if (widget.onBackToHome != null) {
        widget.onBackToHome!(); 
      } else {
        
        Navigator.pop(context); 
      }
    } else if (_currentState == CategoryState.calendar) {
     
      _updateState(CategoryState.calculator);
    } else {
    
      _updateState(CategoryState.view);
    }
  },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF1F2937)),
            ),
          ),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          if (_currentState == CategoryState.calendar)
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context, initialDate: _currentSelectedCalendarDate, firstDate: DateTime(2020), lastDate: DateTime(2030), initialDatePickerMode: DatePickerMode.year, helpText: "SELECT MONTH & YEAR",
                );
                if (picked != null) setState(() { _currentSelectedCalendarDate = DateTime(picked.year, picked.month, 1); });
              },
              child: Row(
                children: [
                  Text(DateFormat('MMM/yyyy').format(_currentSelectedCalendarDate), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                  const Icon(Icons.unfold_more, size: 18, color: Colors.black), 
                ],
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

  Widget _buildCategoryListFiltered(String type) {
    return BlocConsumer<CategoryBloc, CategoryStateBase>(
      listener: (context, state) {
        if (state is CategoryError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.black));
        }
      },
      builder: (context, state) {
        if (state is CategoryLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF7F3DFF)));
        List<CategoryItem> currentCategories = [];
        if (state is CategoryLoaded) currentCategories = state.categories.where((c) => c.type == type).toList();

        // "Add New Category" now lives in a fixed footer below the list
        // instead of being the last scrollable item, so it's always
        // reachable without dragging all the way to the bottom.
        // return Column(
        //   children: [
        //     Expanded(
        //       child: currentCategories.isEmpty
        //           ? const SizedBox.shrink()
        //           : ListView.builder(
        //               padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        //               itemCount: currentCategories.length,
        //               itemBuilder: (context, index) {
        //                 final item = currentCategories[index];
        //                 return Container(
        //                   margin: const EdgeInsets.only(bottom: 12),
        //                   clipBehavior: Clip.antiAlias,
        //                   decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        //                   child: Material(
        //                     color: const Color(0xFFF9FAFB),
        //                     child: ListTile(
        //                       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        //                       onTap: () {
        //                         setState(() { _selectedCategory = item; _amount = "0"; _expression = ""; _shouldResetDisplay = false; });
        //                         _updateState(CategoryState.calculator);
        //                       },
        //                       leading: Container(
        //                         padding: const EdgeInsets.all(2), 
        //                         decoration: BoxDecoration(shape: BoxShape.circle, border: _selectedCategory == item ? Border.all(color: Colors.black, width: 2) : null),
        //                         child: CircleAvatar(radius: 20, backgroundColor: item.color, child: Icon(item.icon, color: Colors.white, size: 20)),
        //                       ),
        //                       title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 15)),
        //                       trailing: IconButton(icon: const Icon(Icons.more_vert, size: 22, color: Color(0xFF9CA3AF)), onPressed: () => _showActionBottomSheet(item)),
        //                     ),
        //                   ),
        //                 );
        //               },
        //             ),
        //     ),
        //     Padding(
        //       padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        //       child: Container(
        //         clipBehavior: Clip.antiAlias,
        //         decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        //         child: Material(
        //           color: const Color(0xFFF9FAFB),
        //           child: ListTile(
        //             contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        //             leading: const Icon(Icons.add, color: Colors.black, size: 24),
        //             title: const Text("Add New Category", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15)),
        //             onTap: () {
        //               _nameController.clear();
        //               _tempColor = const Color(0xFFF59E0B);
        //               _tempIcon = Icons.restaurant;
        //               _tempType = type == 'expense' ? "Expense" : "Income"; 
        //               _updateState(CategoryState.add);
        //             },
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // );

        return Stack(
  children: [
    currentCategories.isEmpty
        ? const SizedBox.shrink()
        : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90), // FAB အတွက် နေရာချန်
            itemCount: currentCategories.length,
            itemBuilder: (context, index) {
              final item = currentCategories[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                child: Material(
                  color: const Color(0xFFF9FAFB),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    onTap: () {
                      setState(() { _selectedCategory = item; _amount = "0"; _expression = ""; _shouldResetDisplay = false; });
                      _updateState(CategoryState.calculator);
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: _selectedCategory == item ? Border.all(color: Colors.black, width: 2) : null),
                      child: CircleAvatar(radius: 20, backgroundColor: item.color, child: Icon(item.icon, color: Colors.white, size: 20)),
                    ),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 15)),
                    trailing: IconButton(icon: const Icon(Icons.more_vert, size: 22, color: Color(0xFF9CA3AF)), onPressed: () => _showActionBottomSheet(item)),
                  ),
                ),
              );
            },
          ),
    Positioned(
      right: 16,
      bottom: 16,
      child: GestureDetector(
        onTap: () {
          _nameController.clear();
          _tempColor = const Color(0xFFF59E0B);
          _tempIcon = Icons.restaurant;
          _tempType = type == 'expense' ? "Expense" : "Income";
          _updateState(CategoryState.add);
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Color(0xFF7F3DFF),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    ),
  ],
);
      },
    );
  }

  Widget _buildDeleteAlertBox(double screenWidth) {
    return Container(
      color: Colors.black38, alignment: Alignment.center,
      child: Container(
        width: screenWidth * 0.82, padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Are you sure you want to delete?", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(onPressed: () => _updateState(CategoryState.view), child: const Text("Cancel", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16))),
                TextButton(
                  onPressed: () {
                    if (_itemToModify != null) {
                      BlocProvider.of<CategoryBloc>(context).add(DeleteCategoryRequested(_itemToModify!.id));
                      BlocProvider.of<TransactionBloc>(context).add(LoadTransactions());
                      _selectedCategory = null; _itemToModify = null;
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
}