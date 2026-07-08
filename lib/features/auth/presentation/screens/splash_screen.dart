import 'dart:async';
import 'package:expense_tracker/features/auth/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  int _currentStage = 1; 

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: -0.785).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
    _executeSplashFlow();
  }

  void _executeSplashFlow() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _currentStage = 2;
      });
      _rotationController.forward();
    }

    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {
        _currentStage = 3;
      });
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    double initialLogoSize = screenWidth * 0.28;
    if (initialLogoSize > 120) initialLogoSize = 120;

    double finalLogoSize = screenWidth * 0.24;
    if (finalLogoSize > 95) finalLogoSize = 95;

    double titleFontSize = screenWidth * 0.075;
    if (titleFontSize > 30) titleFontSize = 30;

    double bodyFontSize = screenWidth * 0.042;
    if (bodyFontSize > 16) bodyFontSize = 16;

    Color backgroundColor = _currentStage == 3 ? const Color(0xFF38BDF8) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500), 
          child: _currentStage < 3
              ? _buildSplashIntroStage(initialLogoSize) 
              : _buildMainSignInStage(screenWidth, screenHeight, finalLogoSize, titleFontSize, bodyFontSize), 
        ),
      ),
    );
  }

  Widget _buildSplashIntroStage(double logoSize) {
    return Center(
      key: const ValueKey('IntroStage'),
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value, 
            child: child,
          );
        },
        child: Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: const Color(0xFF38BDF8), 
            borderRadius: BorderRadius.circular(logoSize * 0.22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              'assets/images/logo.jpg',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.savings_outlined, size: 50, color: Colors.orangeAccent);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainSignInStage(double screenWidth, double screenHeight, double logoSize, double titleFontSize, double bodyFontSize) {
    return Padding(
      key: const ValueKey('MainStage'),
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: screenHeight * 0.15), 
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: logoSize,
                height: logoSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(logoSize * 0.22),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.savings_outlined, size: 40, color: Colors.orangeAccent);
                    },
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.04), 
              Expanded(
                child: Text(
                  "Expense Tracker",
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            "Save money! The more your money works for you, the less you have to work for money.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: bodyFontSize,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.85),
              height: 1.5,
            ),
          ),
          const Spacer(flex: 2),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E6091), 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 1,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.g_mobiledata, color: Colors.blue, size: 22),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Text(
                    "Sign in with google",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: bodyFontSize * 0.95,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.06), 
        ],
      ),
    );
  }
}