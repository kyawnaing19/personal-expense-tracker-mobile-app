import 'package:expense_tracker/features/auth/presentation/bloc/transaction_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/transaction_event.dart';
import 'package:expense_tracker/features/auth/presentation/screens/category_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/home_screen.dart' hide CategoryState;
import 'package:expense_tracker/features/auth/presentation/screens/record_history_screen.dart' hide CategoryState;
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/auth/presentation/screens/AnalyticsScreen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/ProfileScreen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentTabIndex = 0; // ကနဦး Index 0 (Home)
  CategoryState _currentState = CategoryState.view; // Category State ကို ထိန်းရန်

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    
    // 🎯 _pages List ကို တည်ဆောက်ပြီး RecordHistoryScreen ထံ callback လှမ်းပေးပါသည်[cite: 2]
    _pages = [
      const HomeScreen(),           // Index 0
      const AnalyticsScreen(),      // Index 1 (အစ်မထည့်ထားသော icon logic အတိုင်း)
      const CategoryScreen(),       // Index 2 (Add icon နေရာ)
      
      // 🎯 Back Arrow နှိပ်လျှင် Home Tab (Index 0) သို့ Live ပြန်သွားစေမည့်အပိုင်း[cite: 2]
      RecordHistoryScreen(
        onTabChanged: (index) {
          setState(() {
            _currentTabIndex = index; // ⬅️ တကယ့် Tab Index ကို 0 (Home) သို့ ပြောင်းလဲပေးလိုက်ပါပြီ
          });
        },
      ),                        // Index 3
      
      const ProfileScreen(),        // Index 4
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🎯 IndexedStack ဖြင့် Screen ပြောင်းလဲမှုများကို ကိုင်တွယ်ပါသည်[cite: 2]
      body: IndexedStack(
        index: _currentTabIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
Widget _buildBottomNavigationBar() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double tabWidth = screenWidth / 5;
    
    final List<IconData> navIcons = [
      Icons.home_outlined, 
      Icons.pie_chart_outline, 
      Icons.add, 
      Icons.assignment_outlined, 
      Icons.person_outline,
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
                color: Color(0xFF8B5CF6), 
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
                    onTap: () {
                      // 🎯 [LIVE FIX] Navigator.push အဟောင်းတွေ လုံးဝမပါတော့ပါဘူး။ 
                      // နှိပ်လိုက်တဲ့ Tab Index အတိုင်း တိုက်ရိုက် Live ပြောင်းလဲပေးမှာဖြစ်ပါတယ်
                      setState(() {
                        _currentTabIndex = index;
                        if (index == 2 || index == 3) {
                          _currentState = CategoryState.view;
                        }
                      });

                      // History Tab (Index 3) ကို နှိပ်ရင် ဒေတာအသစ် Live ဆွဲခေါ်ရန်
                      if (index == 3) {
                        BlocProvider.of<TransactionBloc>(context).add(LoadTransactions());
                      }
                    },
                    child: Center(
                      child: isSelected 
                          ? const SizedBox.shrink() 
                          : Icon(navIcons[index], size: 26, color: Colors.black), 
                    ),
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
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill; 
      
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
  bool shouldRepaint(covariant NavCurvePainter oldDelegate) => 
      oldDelegate.selectedIndex != selectedIndex || oldDelegate.tabWidth != tabWidth;
}