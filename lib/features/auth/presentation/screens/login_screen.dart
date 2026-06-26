import 'package:expense_tracker/features/auth/presentation/screens/category_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // ၁။ Login အောင်မြင်ရင် ပုံမှန်အတိုင်း CategoryScreen ကို တိုက်ရိုက် သွားမည်
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CategoryScreen()),
            );
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            // Figma အတိုင်း အပြာရောင် Gradient နောက်ခံ ပြုလုပ်ခြင်း
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 63, 143, 196), 
                  Color.fromARGB(255, 89, 163, 223), 
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // ၂။ App Logo
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ],
                        image: const DecorationImage(
                          image: AssetImage('assets/images/logo.jpg'), // logo.jpg လမ်းကြောင်း
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ၃။ App Name
                    const Text(
                      'Expense Tracker',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // စာသားကို အဖြူရောင်ပြောင်း
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ၄။ UI ထဲက Quote စာသားလေး
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        'Save money! The more your money works for you, the less you have to work for money.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70, 
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    
                    const Spacer(),

                    // ၅။ Google Sign In Button အပိုင်း
                    state is AuthLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : ElevatedButton(
                            onPressed: () {
                              context.read<AuthBloc>().add(GoogleLoginRequested());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              minimumSize: const Size(double.infinity, 54),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30), 
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://www.google.com/favicon.ico',
                                  width: 22,
                                  height: 22,
                                ),
                                const SizedBox(width: 14),
                                const Text(
                                  'Sign in with Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ရုပ်ထွက်ပိုလှစေရန် တောက်ပမှုကို ထိန်းညှိဖို့ သုံးသော စာသားအရောင်
extension on Colors {
  static const Color whiteEfficacy = Color(0xFFE0E8F9);
}