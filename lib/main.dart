import 'package:expense_tracker/features/auth/presentation/screens/MainNavigationScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_tracker/features/auth/data/auth_repository.dart';
import 'package:expense_tracker/features/auth/data/category_repository.dart';
import 'package:expense_tracker/features/auth/data/transaction_repository.dart'; 
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/transaction_bloc.dart'; 
import 'package:expense_tracker/features/auth/presentation/screens/login_screen.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  
  
  await Hive.initFlutter();
  await Hive.openBox('categories_cache');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider<CategoryRepository>(
          create: (context) => CategoryRepository(),
        ),
        RepositoryProvider<TransactionRepository>(
          create: (context) => TransactionRepository(), 
        ),
      ],
     
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              RepositoryProvider.of<AuthRepository>(context),
            )..add(CheckAuthStatus()), 
          ),
          BlocProvider<CategoryBloc>(
            create: (context) => CategoryBloc(
              RepositoryProvider.of<CategoryRepository>(context),
            )..add(LoadCategories()), 
          ),
          BlocProvider<TransactionBloc>(
            create: (context) => TransactionBloc(
              RepositoryProvider.of<TransactionRepository>(context),
            ), 
          ),
        ],
      
        child: MaterialApp(
          title: 'Expense Tracker',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
          ),
        

          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return const MainNavigationScreen();
              }
              if (state is AuthLoading || state is AuthInitial) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(), 
                  ),
                );
              }
                return const LoginScreen(); 
            },
          ),
        ),
      ),
    );
  }
}