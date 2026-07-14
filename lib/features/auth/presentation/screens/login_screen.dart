import 'package:expense_tracker/features/auth/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  static const Color _accent = Color(0xFF8B5CF6); // purple accent used throughout

  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  late PageController _onboardPageController;

  // 1 = rotating logo intro, 2 = onboarding carousel (last page has the Google button)
  int _currentStage = 1;
  int _onboardIndex = 0;

  final List<_OnboardData> _onboardPages = const [
    _OnboardData(
      image: 'assets/images/onboarding1.jpg',
      title: 'Always take control\nof your finance',
      description:
          'Finances must be arranged to set a better lifestyle in the future.',
    ),
    _OnboardData(
      image: 'assets/images/onboarding2.jpg',
      title: 'See Where Your Money\nGoes',
      description:
          'Track your expenses by category with clear visual breakdowns that reveal your spending habits and help you save more.',
    ),
    _OnboardData(
      image: 'assets/images/onboarding3.jpg',
      title: 'Stay Within Your Limits',
      description:
          'Set monthly budgets for different categories and get alerts before you overspend.',
    ),
    _OnboardData(
      image: 'assets/images/onboarding4.jpg',
      title: 'Track Group Expenses',
      description:
          'Easily split bills with friends and keep track of shared debts without the headache.',
    ),
    _OnboardData(
      image: 'assets/images/onboarding5.jpg',
      title: 'Never Miss a Payment',
      description:
          'Set up recurring transactions and get smart notifications to remind you.',
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
        _currentStage = 2; // move into the onboarding carousel
      });
    }
  }

  void _skipToEnd() {
    _onboardPageController.animateToPage(
      _onboardPages.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _goNext() {
    _onboardPageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _goBack() {
    _onboardPageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _onboardPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }

          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _currentStage == 1
                ? _buildSplashIntroStage()
                : _buildOnboardingStage(context, state),
          );
        },
      ),
    );
  }

  // Stage 1: rotating logo intro (matches the video)
  Widget _buildSplashIntroStage() {
    final screenWidth = MediaQuery.of(context).size.width;
    double logoSize = screenWidth * 0.28;
    if (logoSize > 120) logoSize = 120;

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
         // child: Padding(
            //padding: const EdgeInsets.all(12.0),
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
     // ),
    );
  }

  // Stage 2: 5-page onboarding carousel. The last page carries the
  // "Sign in with Google" button, wired to the same AuthBloc as before.
  Widget _buildOnboardingStage(BuildContext context, AuthState state) {
    return SafeArea(
      key: const ValueKey('OnboardingStage'),
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: AnimatedBuilder(
              animation: _onboardPageController,
              builder: (context, _) {
                final isLastPage = _onboardIndex == _onboardPages.length - 1;
                return isLastPage
                    ? const SizedBox.shrink()
                    : Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20, top: 4),
                          child: TextButton(
                            onPressed: _skipToEnd,
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
                      );
              },
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _onboardPageController,
              itemCount: _onboardPages.length,
              onPageChanged: (index) => setState(() => _onboardIndex = index),
              itemBuilder: (context, index) {
                final page = _onboardPages[index];
                final isLastPage = index == _onboardPages.length - 1;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Image.asset(
                        page.image,
                        height: 220,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(
                          height: 220,
                          child: Icon(Icons.image_outlined,
                              size: 100, color: Colors.black26),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _onboardPages.length,
                          (dotIndex) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _onboardIndex == dotIndex ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _onboardIndex == dotIndex
                                  ? _accent
                                  : Colors.black12,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        page.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.45),
                          height: 1.5,
                        ),
                      ),
                      if (isLastPage) ...[
                        const SizedBox(height: 28),
                        state is AuthLoading
                            ? const CircularProgressIndicator(color: _accent)
                            : SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: OutlinedButton(
                                  onPressed: () {
                                    context
                                        .read<AuthBloc>()
                                        .add(GoogleLoginRequested());
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Colors.black12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Image.network(
                                        'https://www.google.com/favicon.ico',
                                        width: 20,
                                        height: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Sign in with Google',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: AnimatedBuilder(
              animation: _onboardPageController,
              builder: (context, _) {
                final isFirstPage = _onboardIndex == 0;
                final isLastPage = _onboardIndex == _onboardPages.length - 1;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 60,
                      child: isFirstPage
                          ? const SizedBox.shrink()
                          : TextButton(
                              onPressed: _goBack,
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  alignment: Alignment.centerLeft),
                              child: const Text(
                                'BACK',
                                style: TextStyle(
                                  color: _accent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),
                    Text(
                      'Page ${_onboardIndex + 1} of ${_onboardPages.length}',
                      style: const TextStyle(
                        color: Colors.black38,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: isLastPage
                          ? const SizedBox.shrink()
                          : TextButton(
                              onPressed: _goNext,
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  alignment: Alignment.centerRight),
                              child: Text(
                                isFirstPage ? 'START' : 'NEXT',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: _accent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
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