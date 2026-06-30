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
import 'package:image_picker/image_picker.dart';

List<RecordItem> globalRecords = [];
enum CategoryState { view, calculator, deleteConfirm, add, edit, calendar }

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with SingleTickerProviderStateMixin {
  CategoryState _currentState = CategoryState.view;
  int _currentTabIndex = 2;
  
  late TabController _tabController;

  // 🧮 Calculator State Variables
  String _amount = "0";             
  String _expression = "";          
  double? _firstOperand;            
  String? _currentOperator;         
  bool _shouldResetDisplay = false; 

  final List<Color> _availableColors = [
    const Color(0xFF6366F1), const Color(0xFF10B981), const Color(0xFFF59E0B),
    const Color(0xFFEF4444), const Color(0xFFEC4899), const Color(0xFF06B6D4),
    const Color(0xFF8B5CF6), const Color(0xFF14B8A6), const Color(0xFFF43F5E),
    const Color(0xFF84CC16), const Color(0xFF3B82F6), const Color(0xFFEAB308),
    const Color(0xFF6B7280), const Color(0xFF9A3412), const Color.fromARGB(255, 233, 243, 90),
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
  
  Color _tempColor = const Color(0xFF6366F1);
  IconData _tempIcon = Icons.restaurant;
  String _tempType = "Expense"; 
  
  XFile? _pickedImage;
  String _calendarHeaderText = "";
  DateTime _currentSelectedCalendarDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _calendarHeaderText = DateFormat('EEE, MMM d, yyyy').format(DateTime.now());
    _tabController = TabController(length: 2, vsync: this);
    BlocProvider.of<CategoryBloc>(context).add(LoadCategories());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose Image Source", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text("Take a Photo (Camera)"),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.camera);
                  if (image != null) setState(() => _pickedImage = image);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) setState(() => _pickedImage = image);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onKeypadPressed(String value) {
    setState(() {
      if (value == "Today") {
        _currentSelectedCalendarDate = DateTime.now();
        _calendarHeaderText = DateFormat('EEE, MMM d, yyyy').format(_currentSelectedCalendarDate);
        _currentState = CategoryState.calendar; 
        return;
      }

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
        _firstOperand = double.tryParse(_amount);
        _currentOperator = value;
        _expression = "${_amount} ${_currentOperator}"; 
        _shouldResetDisplay = true; 
        return;
      }

      if (value == "=") {
        _calculateResult();
        return;
      }

      // if (value == "✓") {
      //   double parsedAmount = double.tryParse(_amount) ?? 0.0;
        
      //   if (parsedAmount == 0.0 || _amount == "0" || _amount == "Error") {
      //     return; 
      //   }

      //   if (_selectedCategory != null) {
      //     String userNote = _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : "No note";
          
      //     BlocProvider.of<TransactionBloc>(context).add(
      //       AddTransactionRequested(
      //         categoryId: _selectedCategory!.id,
      //         amount: parsedAmount,
      //         note: userNote,
      //       ),
      //     );
      //   }
        
      //   _amount = "0";
      //   _expression = "";
      //   _firstOperand = null;
      //   _currentOperator = null;
      //   _shouldResetDisplay = false;
      //   _noteController.clear();
      //   _pickedImage = null;
      //   _selectedCategory = null;
      //   _currentState = CategoryState.view;
      //   return;
      // }
      if (value == "✓") {
        double parsedAmount = double.tryParse(_amount) ?? 0.0;
        
        if (parsedAmount == 0.0 || _amount == "0" || _amount == "Error") {
          return; 
        }

        if (_selectedCategory != null) {
          String userNote = _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : "No note";
          
          // ၁။ ဒေတာအသစ် လှမ်းထည့်သည်[cite: 3]
          BlocProvider.of<TransactionBloc>(context).add(
            AddTransactionRequested(
              categoryId: _selectedCategory!.id,
              amount: parsedAmount,
              note: userNote,
            ),
          );

          // 🎯 ၂။ [အဓိက ပြင်ဆင်ချက်] ဒေတာတွေ ကော၊ သက်ဆိုင်ရာ Category State တွေကော Live Update ဖြစ်စေရန် Event ၂ ခုလုံး ခေါ်ပေးရပါမယ်[cite: 3]
          BlocProvider.of<TransactionBloc>(context).add(LoadTransactions());
          BlocProvider.of<CategoryBloc>(context).add(LoadCategories()); 
        }
        
        _amount = "0";
        _expression = "";
        _firstOperand = null;
        _currentOperator = null;
        _shouldResetDisplay = false;
        _noteController.clear();
        _pickedImage = null;
        _selectedCategory = null;
        _currentState = CategoryState.view;
        return;
      }

      if (value == ".") {
        if (_shouldResetDisplay || _amount == "Error") {
          _amount = "0.";
          _shouldResetDisplay = false;
        } else if (!_amount.contains(".")) {
          _amount += ".";
        }
        return;
      }

      if (_shouldResetDisplay || _amount == "Error") {
        _amount = value;
        _shouldResetDisplay = false;
      } else {
        if (_amount == "0") {
          _amount = value; 
        } else {
          _amount += value; 
        }
      }
    });
  }

  void _calculateResult() {
    if (_firstOperand == null || _currentOperator == null) return;
    
    double secondOperand = double.tryParse(_amount) ?? 0;
    double result = 0;

    switch (_currentOperator) {
      case "+": result = _firstOperand! + secondOperand; break;
      case "-": result = _firstOperand! - secondOperand; break;
      case "×": result = _firstOperand! * secondOperand; break;
      case "÷":
        if (secondOperand != 0) {
          result = _firstOperand! / secondOperand;
        } else {
          _amount = "Error"; _expression = ""; _firstOperand = null; _currentOperator = null;
          return;
        }
        break;
    }

    if (result % 1 == 0) {
      _amount = result.toInt().toString();
    } else {
      _amount = result.toStringAsFixed(2); 
    }
    
    _firstOperand = null;
    _currentOperator = null;
    _expression = ""; 
  }

  void _showActionBottomSheet(CategoryItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit Category', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _itemToModify = item;
                  _nameController.text = item.name;
                  _tempColor = item.color;
                  _tempIcon = item.icon;
                  _tempType = item.type == 'expense' ? "Expense" : "Income";
                  _currentState = CategoryState.edit;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Category', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _itemToModify = item;
                  _currentState = CategoryState.deleteConfirm;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
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
                            TabBar(
                              controller: _tabController,
                              labelColor: const Color(0xFF6366F1),
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: const Color(0xFF6366F1),
                              indicatorWeight: 3,
                              tabs: const [
                                Tab(text: "Expense"),
                                Tab(text: "Income"),
                              ],
                            ),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
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
                // if (_currentState == CategoryState.view ||
                //     _currentState == CategoryState.deleteConfirm)
                //   _buildBottomNavigationBar(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    if (_currentState == CategoryState.calendar) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
              onPressed: () => setState(() => _currentState = CategoryState.calculator),
            ),
            const SizedBox(), 
            IconButton(
              icon: const Icon(Icons.close, size: 24, color: Colors.black),
              onPressed: () => setState(() {
                _selectedCategory = null;
                _currentState = CategoryState.view; 
              }),
            ),
          ],
        ),
      );
    }

    String title = "Category";
    if (_currentState == CategoryState.add) title = "Add Category";
    if (_currentState == CategoryState.edit) title = "Edit Category";
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () => setState(() => _currentState = CategoryState.view),
          ),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.close, size: 22),
            onPressed: () => setState(() {
              _selectedCategory = null; 
              _currentState = CategoryState.view;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryListFiltered({required String type}) {
    return BlocConsumer<CategoryBloc, CategoryStateBase>(
      listener: (context, state) {
        if (state is CategoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color.fromARGB(255, 14, 13, 13),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
        }

        List<CategoryItem> currentCategories = [];
        if (state is CategoryLoaded) {
          currentCategories = state.categories.where((c) => c.type == type).toList();
        }

        return ListView.builder(
          itemCount: currentCategories.length + 1,
          itemBuilder: (context, index) {
            if (index == currentCategories.length) {
              return ListTile(
                leading: const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Icon(Icons.add, color: Colors.grey),
                ),
                title: Text("Add New ${type == 'expense' ? 'Expense' : 'Income'} Category", 
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                onTap: () => setState(() {
                  _nameController.clear();
                  _tempColor = _availableColors.first;
                  _tempIcon = _availableIcons.first;
                  _tempType = type == 'expense' ? "Expense" : "Income"; 
                  _currentState = CategoryState.add;
                }),
              );
            }

            final item = currentCategories[index];
            bool isSelected = _selectedCategory?.id == item.id;

            return ListTile(
              onTap: () => setState(() {
                _selectedCategory = item;
                _amount = "0"; _expression = ""; _firstOperand = null; _currentOperator = null; _shouldResetDisplay = false;
                _currentState = CategoryState.calculator;
              }),
              leading: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? Colors.black : Colors.transparent, width: 2.5),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: item.color,
                  child: Icon(item.icon, color: Colors.white, size: 20),
                ),
              ),
              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(
                item.type.toUpperCase(),
                style: TextStyle(fontSize: 11, color: item.type == 'expense' ? Colors.grey : Colors.green, fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert, size: 22, color: Colors.black54),
                onPressed: () => _showActionBottomSheet(item),
              ),
            ); // <-- ListTile ပိတ်တာက ဒီနေရာမှာပဲ ဖြစ်ရပါမယ်
          },
        );
      },
    );
  }

  Widget _buildCalculatorSection(double screenWidth) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: const Color(0xFFE5E7EB),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_expression.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  _expression, 
                  style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.assignment_outlined, color: Colors.black54),
                Text(_amount, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: "Note: Enter a note ......",
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: Icon(_pickedImage != null ? Icons.check_circle : Icons.camera_alt_outlined, 
                             color: _pickedImage != null ? Colors.green : Colors.grey),
                  onPressed: _showImageSourceDialog,
                ), 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), 
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 10),
            _buildBalancedKeypadUI(), 
          ],
        ),
      ),
    );
  }

  Widget _buildBalancedKeypadUI() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cellHeight = (constraints.maxWidth / 4) * 0.65; 

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          childAspectRatio: (constraints.maxWidth / 4) / cellHeight,
          children: [
            _buildBaseButton("7"), _buildBaseButton("8"), _buildBaseButton("9"), _buildActionButton("Today"),
            _buildBaseButton("4"), _buildBaseButton("5"), _buildBaseButton("6"),
            Row(
              children: [
                Expanded(child: _buildActionButton("+")),
                const SizedBox(width: 4),
                Expanded(child: _buildActionButton("-")),
              ],
            ),
            _buildBaseButton("1"), _buildBaseButton("2"), _buildBaseButton("3"),
            Row(
              children: [
                Expanded(child: _buildActionButton("×")),
                const SizedBox(width: 4),
                Expanded(child: _buildActionButton("÷")),
              ],
            ),
            _buildBaseButton("0"), _buildBaseButton("."), _buildBaseButton("="),
            Row(
              children: [
                Expanded(child: _buildActionButton("⌫")),
                const SizedBox(width: 4),
                Expanded(child: _buildActionButton("✓")),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildBaseButton(String label) {
    bool isEquals = label == "=";
    bool isDot = label == ".";
    double fontSize = isDot ? 26 : 18; 

    return GestureDetector(
      onTap: () => _onKeypadPressed(label),
      child: Container(
        decoration: BoxDecoration(
          color: isEquals ? const Color(0xFF6366F1) : Colors.white, 
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: isEquals ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label) {
    bool isToday = label == "Today";
    bool isConfirm = label == "✓";
    bool isBackspace = label == "⌫";
    bool isOperator = label == "+" || label == "-" || label == "×" || label == "÷";

    Color textColor = Colors.black;
    if (isConfirm) {
      textColor = (_amount == "0" || _amount == "Error") ? Colors.grey : Colors.green;
    } else if (isToday) {
      textColor = Colors.blue;
    } else if (isBackspace) {
      textColor = Colors.redAccent;
    } else if (isOperator) {
      textColor = Colors.orangeAccent;
    }

    double fontSize = isOperator ? 22 : (isToday ? 13 : 16);

    return GestureDetector(
      onTap: () => _onKeypadPressed(label),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  // ⭐ [FIXED DELETE CONFIRMATION BOX]
  Widget _buildDeleteAlertBox(double screenWidth) {
    return Container(
      color: Colors.black26,
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
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => setState(() => _currentState = CategoryState.view),
                  child: const Text("Cancel", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                TextButton(
                  onPressed: () {
                    if (_itemToModify != null) {
                      // 1. 🛑 [FIXED] Event Name အမှန်ဖြစ်သော DeleteCategory သို့ ပြောင်းလဲခေါ်ဆိုခြင်း
                      //BlocProvider.of<CategoryBloc>(context).add(DeleteCategoryRequested(_itemToModify!.id));
                      //BlocProvider.of<CategoryBloc>(context).add(DeleteCategoryRequested(id: _itemToModify!.id));
                      BlocProvider.of<CategoryBloc>(context).add(DeleteCategoryRequested(_itemToModify!.id));
                      
                      // 2. 🔄 [API REFRESH] Category ပျက်လျှင် သက်ဆိုင်ရာ transaction များပါ ချက်ချင်း ပျောက်သွားစေရန်
                      BlocProvider.of<TransactionBloc>(context).add(LoadTransactions());

                      _selectedCategory = null;
                      _itemToModify = null;
                      setState(() => _currentState = CategoryState.view);
                    // _currentState = CategoryState.view;
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormInputs(isDisableType: true), 
          const SizedBox(height: 16),
          const Text("Choose colour & icon", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildColorPicker(),
          const SizedBox(height: 14),
          Expanded(child: _buildIconGrid(constraints)),
          _buildSaveButton(
            label: "+ Add Category",
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
                setState(() => _currentState = CategoryState.view);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEditCategoryView(BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormInputs(isDisableType: true), 
          const SizedBox(height: 16),
          const Text("Choose colour", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildColorPicker(),
          const Spacer(),
          _buildSaveButton(
            label: "Save",
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
                setState(() => _currentState = CategoryState.view);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView(double screenWidth) {
    final List<String> weekdays = ["S", "M", "T", "W", "T", "F", "S"];
    final List<String> days = [
      "31", "1", "2", "3", "4", "5", "6",
      "7", "8", "9", "10", "11", "12", "13",
      "14", "15", "16", "17", "18", "19", "20",
      "21", "22", "23", "24", "25", "26", "27",
      "28", "29", "30", "1", "2", "3", "4"
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(_calendarHeaderText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays.map((w) => SizedBox(
              width: screenWidth / 8,
              child: Text(w, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            )).toList(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              itemCount: days.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, mainAxisSpacing: 18, crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                String day = days[index];
                bool isCurrentMonth = !(index == 0 || index > 30);
                bool isSelectedDay = isCurrentMonth && (int.tryParse(day) == _currentSelectedCalendarDate.day);
                return GestureDetector(
                  onTap: () {
                    if (isCurrentMonth) {
                      setState(() {
                        int selectedDayInt = int.parse(day);
                        _currentSelectedCalendarDate = DateTime(DateTime.now().year, DateTime.now().month, selectedDayInt);
                        _calendarHeaderText = DateFormat('EEE, MMM d, yyyy').format(_currentSelectedCalendarDate);
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelectedDay ? const Color(0xFF38BDF8) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelectedDay ? FontWeight.bold : FontWeight.w500,
                        color: isSelectedDay ? Colors.white : (isCurrentMonth ? Colors.black : Colors.grey[400]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: _buildSaveButton(
              label: "Done", 
              onPressed: () => setState(() => _currentState = CategoryState.calculator),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFormInputs({bool isDisableType = false}) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Icon", style: TextStyle(color: Colors.grey, fontSize: 15)),
          trailing: CircleAvatar(backgroundColor: _tempColor, radius: 18, child: Icon(_tempIcon, color: Colors.white, size: 18)),
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Name", style: TextStyle(color: Colors.grey, fontSize: 15)),
          trailing: SizedBox(
            width: 180,
            child: TextField(
              controller: _nameController,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                hintText: "Enter Category Name",
                border: InputBorder.none,
                suffixIcon: Icon(Icons.edit, size: 14, color: Colors.grey),
              ),
            ),
          ),
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Type", style: TextStyle(color: Colors.grey, fontSize: 15)),
          trailing: isDisableType 
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(_tempType, style: const TextStyle(color: Colors.black54, fontSize: 15, fontWeight: FontWeight.bold)),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _tempType,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                    style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w500),
                    onChanged: (String? newValue) {
                      if (newValue != null) setState(() => _tempType = newValue);
                    },
                    items: <String>['Expense', 'Income'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                  ),
                ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildColorPicker() {
    return SizedBox(
      height: 44,
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
              width: 38,
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
    int crossAxisCount = constraints.maxWidth > 600 ? 7 : 5;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, mainAxisSpacing: 14, crossAxisSpacing: 14
      ),
      itemCount: _availableIcons.length,
      itemBuilder: (context, index) {
        final icon = _availableIcons[index];
        bool isSelected = _tempIcon == icon;
        return GestureDetector(
          onTap: () => setState(() => _tempIcon = icon),
          child: CircleAvatar(
            backgroundColor: isSelected ? const Color(0xFFFCE7F3) : const Color(0xFFF3F4F6),
            child: Icon(icon, color: isSelected ? const Color(0xFFDB2777) : Colors.grey[600]),
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
          backgroundColor: const Color(0xFF6366F1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

 }