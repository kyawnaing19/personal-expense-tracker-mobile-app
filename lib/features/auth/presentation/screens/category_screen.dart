import 'package:expense_tracker/features/auth/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/category_state.dart';
import 'package:expense_tracker/features/auth/presentation/screens/record_history_screen.dart';
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

  final List<Color> _availableColors = [
    const Color(0xFF6366F1), // Indigo
    const Color(0xFF10B981), // Emerald Green
    const Color(0xFFF59E0B), // Amber Orange
    const Color(0xFFEF4444), // Red
    const Color(0xFFEC4899), // Pink
    const Color(0xFF06B6D4), // Cyan Blue
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFF14B8A6), // Teal
    const Color(0xFFF43F5E), // Rose
    const Color(0xFF84CC16), // Lime Green
    const Color(0xFF3B82F6), // Blue
    const Color(0xFFEAB308), // Yellow
    const Color(0xFF6B7280), // Slate Grey
    const Color(0xFF9A3412), // Rust Brown
    const Color.fromARGB(255, 233, 243, 90),
  ];

  final List<IconData> _availableIcons = [
    Icons.restaurant,          // Food & Drinks
    Icons.shopping_bag,        // Shopping
    Icons.directions_car,      // Transport / Car
    Icons.home,                // House Rent / Property
    Icons.local_hospital,      // Medical / Health
    Icons.school,              // Education
    Icons.flight,              // Travel
    Icons.movie,               // Entertainment
    Icons.fitness_center,      // Gym / Sports
    Icons.dry_cleaning,        // Laundry / Clothes
    Icons.pets,                // Pets Care
    Icons.wifi,                // Internet / Phone Bill
    Icons.build,               // Maintenance / Repairs
    Icons.card_giftcard,       // Gifts / Donations
    Icons.attach_money,        // Salary
    Icons.payments,            // Freelance / Bonus
    Icons.trending_up,         // Investments / Stocks
    Icons.storefront,          // Business Profit
    Icons.account_balance,     // Bank Transfer
    Icons.calendar_month_outlined,    
    Icons.handshake,     // Tips / Others
    Icons.phone,
    Icons.school_outlined,
    Icons.music_note_outlined,
    Icons.headphones,
    Icons.local_cafe,
    Icons.health_and_safety,
    Icons.computer,
  
  ];

  CategoryItem? _selectedCategory;
  CategoryItem? _itemToModify;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  
  Color _tempColor = const Color(0xFF6366F1);
  IconData _tempIcon = Icons.restaurant;
  String _tempType = "Expense"; 
  
  String _amount = "0.00";
  XFile? _pickedImage;
  String _calendarHeaderText = "";
  
  DateTime _currentSelectedCalendarDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _calendarHeaderText = DateFormat('EEE, MMM d, yyyy').format(DateTime.now());
    _tabController = TabController(length: 2, vsync: this);
    
    // Login ဝင်ဝင်ချင်းမှာ Static data တွေမပြဘဲ၊ Server ထဲက User ဒေတာတွေကို ဆွဲထုတ်ရန်အချက်
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
      if (value == "⌫") {
        if (_amount != "0.00") {
          String digits = _amount.replaceAll('.', '');
          digits = digits.substring(0, digits.length - 1);
          if (digits.isEmpty) digits = "0";
          double amountDouble = double.parse(digits) / 100;
          _amount = amountDouble.toStringAsFixed(2);
        }
      } else if (value == "✓") {
        double parsedAmount = double.tryParse(_amount) ?? 0.0;
        if (parsedAmount > 0 && _selectedCategory != null) {
          String formattedTime = DateFormat('dd/MM HH:mm:ss').format(_currentSelectedCalendarDate);
          String userNote = _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : "No note";
          String txType = _selectedCategory!.type;
          String formattedAmountDisplay = txType == 'income' 
              ? "+${NumberFormat('#,##0.00').format(parsedAmount)}"
              : "-${NumberFormat('#,##0.00').format(parsedAmount)}";

          globalRecords.add(
            RecordItem(
              title: _selectedCategory!.name, 
              note: userNote,                 
              time: formattedTime,
              amount: formattedAmountDisplay,
              type: txType,
              icon: _selectedCategory!.icon,
              color: _selectedCategory!.color,
            ),
          );
        }
        _amount = "0.00";
        _noteController.clear();
        _pickedImage = null;
        _selectedCategory = null;
        _currentState = CategoryState.view;
      } else if (value == "Today") {
        _currentSelectedCalendarDate = DateTime.now();
        _calendarHeaderText = DateFormat('EEE, MMM d, yyyy').format(_currentSelectedCalendarDate);
        _currentState = CategoryState.calendar; 
      } else if (int.tryParse(value) != null) {
        String digits = _amount.replaceAll('.', '');
        if (digits == "000") digits = "";
        digits += value;
        double amountDouble = double.parse(digits) / 100;
        _amount = amountDouble.toStringAsFixed(2);
      }
    });
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
                if (_currentState == CategoryState.view || _currentState == CategoryState.deleteConfirm)
                  _buildBottomNavigationBar(),
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

  // User ဆောက်ထားတဲ့ Data အစစ်တွေပဲ ပြမယ့် နေရာ (Static ဒေတာ လုံးဝမပါပါ)
  Widget _buildCategoryListFiltered({required String type}) {
    return BlocBuilder<CategoryBloc, CategoryStateBase>(
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
        color: const Color(0xFFE5E7EB),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.assignment_outlined, color: Colors.black54),
                Text(_amount, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 12),
            _buildCalculatorKeys(),
          ],
        ),
      ),
    );
  }

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
                      BlocProvider.of<CategoryBloc>(context).add(DeleteCategoryRequested(_itemToModify!.id));
                      _selectedCategory = null;
                      setState(() => _currentState = CategoryState.view);
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

  Widget _buildCalculatorKeys() {
    final List<String> keys = [
      "7", "8", "9", "Today",
      "4", "5", "6", "+",
      "1", "2", "3", "×",
      ".", "0", "⌫", "✓"
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, childAspectRatio: 2.1, mainAxisSpacing: 4, crossAxisSpacing: 4
      ),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _onKeypadPressed(keys[index]),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
            child: Center(
              child: Text(
                keys[index], 
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: keys[index] == "✓" ? Colors.green : (keys[index] == "Today" ? Colors.blue : Colors.black)
                )
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double tabWidth = screenWidth / 5;
    final List<IconData> navIcons = [
      Icons.home_outlined, Icons.pie_chart_outline, Icons.add, Icons.assignment_outlined, Icons.person_outline,
    ];
    return Container(
      width: screenWidth,
      height: 65,
      color: Colors.white,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0, right: 0, top: 0, bottom: 0,
            child: CustomPaint(painter: NavCurvePainter(selectedIndex: _currentTabIndex, tabWidth: tabWidth)),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: (_currentTabIndex * tabWidth) + (tabWidth / 2) - 24,
            top: -15,
            child: Container(
              width: 48, height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF38BDF8),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: Icon(navIcons[_currentTabIndex], color: Colors.black, size: 26),
            ),
          ),
          Positioned(
            left: 0, right: 0, top: 0, bottom: 0,
            child: Row(
              children: List.generate(navIcons.length, (index) {
                bool isSelected = _currentTabIndex == index;
                return SizedBox(
                  width: tabWidth,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () async {
                      if (index == 3) {
                        setState(() => _currentTabIndex = index);
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => const RecordHistoryScreen()));
                        setState(() {
                          _currentTabIndex = 2;
                          _currentState = CategoryState.view;
                        });
                      } else {
                        setState(() {
                          _currentTabIndex = index;
                          if (index == 2) _currentState = CategoryState.view;
                        });
                      }
                    },
                    child: Center(child: isSelected ? const SizedBox.shrink() : Icon(navIcons[index], size: 26, color: Colors.black54)),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class NavCurvePainter extends CustomPainter {
  final int selectedIndex;
  final double tabWidth;
  NavCurvePainter({required this.selectedIndex, required this.tabWidth});
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = const Color(0xFFE5E7EB)..style = PaintingStyle.fill;
    final Path path = Path();
    double startingX = selectedIndex * tabWidth;
    path.moveTo(0, 0);
    path.lineTo(startingX, 0);
    path.cubicTo(startingX + (tabWidth * 0.15), 0, startingX + (tabWidth * 0.20), -22, startingX + (tabWidth * 0.50), -22);
    path.cubicTo(startingX + (tabWidth * 0.80), -22, startingX + (tabWidth * 0.85), 0, startingX + tabWidth, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant NavCurvePainter oldDelegate) => oldDelegate.selectedIndex != selectedIndex || oldDelegate.tabWidth != tabWidth;
}