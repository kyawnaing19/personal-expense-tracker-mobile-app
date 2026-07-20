import 'package:expense_tracker/features/auth/presentation/screens/analytics_record_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/category_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/home_screen.dart' hide CategoryState;
import 'package:expense_tracker/features/auth/presentation/screens/record_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/auth/presentation/screens/ProfileScreen.dart';
import 'category_states.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentTabIndex = 0;
  CategoryState _currentState = CategoryState.view;

void onTabTapped(int index) {
  setState(() {
    _currentTabIndex = index;
    if (index == 2 || index == 3) {
      _currentState = CategoryState.view;
    }
  });
  
  if (index == 1) {
    _analyticsKey.currentState?.refreshCurrentSelection();
  }
}

  final GlobalKey<AnalyticalRecordPageState> _analyticsKey =
      GlobalKey<AnalyticalRecordPageState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
  HomeScreen(onNavigateToHistory: () => onTabTapped(3)),
  AnalyticalRecordPage(
    key: _analyticsKey,
    onBackToHome: () => onTabTapped(0),
  ),
  CategoryScreen(
    onBackToHome: () { setState(() { _currentTabIndex = 0; }); },
    onStateChanged: (state) { setState(() { _currentState = state; }); },
  ),
  RecordHistoryScreen(
    onTabChanged: (index) { setState(() { _currentTabIndex = index; }); },
  ),
  ProfileScreen(),
];
  }


  @override
Widget build(BuildContext context) {
  bool shouldHideNavBar = _currentTabIndex == 2 && (_currentState != CategoryState.view);

  return PopScope(
    canPop: _currentTabIndex == 0,
    onPopInvokedWithResult: (bool didPop, dynamic result) {
      if (didPop) return; 
      setState(() {
        _currentTabIndex = 0;
        _currentState = CategoryState.view;
      });
    },
    child: Scaffold(
      backgroundColor: const Color(0xFFE8DEF8),
      body: IndexedStack(
        index: _currentTabIndex,
        children: _pages,
      ),
      bottomNavigationBar: shouldHideNavBar
          ? const SizedBox.shrink()
          : _buildBottomNavigationBar(),
    ),
  );
}

  Widget _buildBottomNavigationBar() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double tabWidth = screenWidth / 5;

    final List<IconData> navIcons = [
      Icons.home_outlined,
      Icons.pie_chart_outline,
      Icons.category_outlined,
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
                      setState(() {
                        _currentTabIndex = index;
                        if (index == 2 || index == 3) {
                          _currentState = CategoryState.view;
                        }
                      });

                      if (index == 1) {
                        _analyticsKey.currentState?.refreshCurrentSelection();
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}