import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  late PageController _onboardPageController;

  int _currentStage = 1;
  int _onboardIndex = 0;

  final List<_OnboardData> _onboardPages = const [
    _OnboardData(
      image: 'assets/images/onboarding1.jpg',
      title: 'Never Miss a Due Date',
      description:
          'Get timely reminders for your bills so you never pay a late fee again.',
    ),
    _OnboardData(
      image: 'assets/images/onboarding2.jpg',
      title: 'Track Every Expense',
      description:
          'Log your daily spending in seconds and see exactly where your money goes.',
    ),
    _OnboardData(
      image: 'assets/images/onboarding3.jpg',
      title: 'Organize Your Finances',
      description:
          'Sort every expense into categories so your budget always makes sense.',
    ),
    _OnboardData(
      image: 'assets/images/onboarding4.jpg',
      title: 'Set Smart Budgets',
      description:
          'Plan monthly budgets and get alerts before you ever overspend.',
    ),
    _OnboardData(
      image: 'assets/images/onboarding5.jpg',
      title: 'Split With Friends',
      description:
          'Share bills and split costs with friends and family, hassle-free.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _onboardPageController = PageController();
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
      _rotationController.forward();
    }

    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() {
        _currentStage = 2; 
      });
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _onNextPressed() {
    if (_onboardIndex == _onboardPages.length - 1) {
      _goToLogin();
    } else {
      _onboardPageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _onboardPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    double initialLogoSize = screenWidth * 0.28;
    if (initialLogoSize > 120) initialLogoSize = 120;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _currentStage == 1
              ? _buildSplashIntroStage(initialLogoSize)
              : _buildOnboardingStage(screenWidth, screenHeight),
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
                return const Icon(Icons.savings_outlined,
                    size: 50, color: Colors.orangeAccent);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingStage(double screenWidth, double screenHeight) {
    return Column(
      key: const ValueKey('OnboardingStage'),
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 12, top: 4),
            child: TextButton(
              onPressed: _goToLogin,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _onboardPageController,
            itemCount: _onboardPages.length,
            onPageChanged: (index) => setState(() => _onboardIndex = index),
            itemBuilder: (context, index) {
              final page = _onboardPages[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      page.image,
                      height: screenHeight * 0.28,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_outlined,
                              size: 100, color: Colors.black26),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      page.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.5),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(
                  _onboardPages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 6),
                    width: _onboardIndex == index ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _onboardIndex == index
                          ? const Color(0xFF1E6091)
                          : Colors.black12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _onNextPressed,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E6091),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _onboardIndex == _onboardPages.length - 1
                        ? Icons.check
                        : Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnboardData {
  final String image;
  final String title;
  final String description;
  const _OnboardData({
    required this.image,
    required this.title,
    required this.description,
  });
}