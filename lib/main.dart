import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_tracker/features/auth/data/auth_repository.dart';
import 'package:expense_tracker/features/auth/data/category_repository.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/auth/presentation/screens/category_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/login_screen.dart';

void main() async {
  //  Flutter Engine ကို အရင်ဆုံး စတင်အလုပ်လုပ်ခိုင်းခြင်း
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive Database ကို ကနဦး စတင်ပွင့်စေပြီး Offline Storage Box အဆင်သင့်ဖွင့်ခြင်း
  await Hive.initFlutter();
  await Hive.openBox('categories_cache');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1️⃣ Repositories များကို တည်ဆောက်ခြင်း
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider<CategoryRepository>(
          create: (context) => CategoryRepository(),
        ),
      ],
      // 2️⃣ BLoCs များကို တည်ဆောက်ပြီး Event များကို စတင်လှမ်းခေါ်ခြင်း
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              RepositoryProvider.of<AuthRepository>(context),
            )..add(CheckAuthStatus()), // Login ဝင်ထားခြင်း ရှိ/မရှိ စစ်ဆေးမည်
          ),
          BlocProvider<CategoryBloc>(
            create: (context) => CategoryBloc(
              RepositoryProvider.of<CategoryRepository>(context),
            )..add(LoadCategories()), // App စဖွင့်သည်နှင့် Local Storage/Server မှ ဒေတာဆွဲယူမည်
          ),
        ],
        // 3️⃣ MaterialApp UI အပိုင်း
        child: MaterialApp(
          title: 'Expense Tracker',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
          ),
          // 4️⃣ Auth State ပေါ်မူတည်ပြီး Screen ခွဲပြခြင်း
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return const CategoryScreen(); // Login ဝင်ပြီးသားဖြစ်ပါက Category UI သို့သွားမည်
              }
              if (state is AuthLoading || state is AuthInitial) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(), // စစ်ဆေးနေစဉ်အတွင်း လည်နေမည်
                  ),
                );
              }
              return const LoginScreen(); // Login မဝင်ရသေးပါက Login Screen ပြမည်
            },
          ),
        ),
      ),
    );
  }
}