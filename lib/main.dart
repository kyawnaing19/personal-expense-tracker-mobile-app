import 'package:expense_tracker/features/auth/data/analytics_repository.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/analytics_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/screens/MainNavigationScreen.dart';
import 'package:expense_tracker/services/local_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 👈 Secure Storage အတွက် ထည့်ပါ
import 'package:expense_tracker/core/network/dio_client.dart'; // 👈 Dio Client အတွက် ထည့်ပါ
import 'package:expense_tracker/core/constants/api_constants.dart'; // 👈 API Constants အတွက် ထည့်ပါ
import 'package:expense_tracker/features/auth/data/auth_repository.dart';
import 'package:expense_tracker/features/auth/data/category_repository.dart';
import 'package:expense_tracker/features/auth/data/transaction_repository.dart'; 
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart' hide AnalyticsBloc;
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/transaction_bloc.dart'; 
import 'package:expense_tracker/features/auth/presentation/screens/login_screen.dart';
import 'package:expense_tracker/features/auth/data/budget_repository.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/budget_bloc.dart';

void main() async {
  // Flutter binding ကို အစပြုခြင်း
  WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp(); // Firebase စတင်ခြင်း

 await LocalNotificationService.initialize();

  // ၂။ Foreground Listener ကို ထည့်ပါ
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      // Pop-up တက်လာစေရန် ခေါ်ပေးခြင်း
      LocalNotificationService.display(message);
      print("Foreground မှာ Notification ရောက်လာပါတယ်: ${message.notification?.title}");
    }
  });
  // ၁။ Firebase ကို Initialize လုပ်ခြင်း
  try {
    await Firebase.initializeApp();
    
    // ၂။ Notification Permission တောင်းခြင်း
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted notification permission: ${settings.authorizationStatus}');

    // 👈 ၃။ App ဖွင့်တိုင်း FCM token refresh ဖြစ်ရင် auto update လုပ်ပေးမယ့် listener ထည့်ခြင်း
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      const storage = FlutterSecureStorage();
      final sanctumToken = await storage.read(key: 'token');

      if (sanctumToken != null) {
        // User login ဝင်နေချိန်မှ update လုပ်မယ်
        final dio = DioClient.getInstance();
        try {
          await dio.post(
            ApiConstants.updateFcmToken,
            data: {'fcm_token': newToken},
          );
          print("FCM Token Auto-Updated: $newToken");
        } catch (e) {
          debugPrint('FCM token auto-update failed: $e');
        }
      }
    });

  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  
  // Hive initialize လုပ်ခြင်း
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
        RepositoryProvider<AnalyticsRepository>(
  create: (context) => AnalyticsRepository(),
),
      RepositoryProvider<BudgetRepository>(
  create: (context) => BudgetRepository(
    RepositoryProvider.of<CategoryRepository>(context),
  ),
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
          BlocProvider<AnalyticsBloc>(
  create: (context) => AnalyticsBloc(
    RepositoryProvider.of<AnalyticsRepository>(context),
  ),
),
       BlocProvider<BudgetBloc>(
  create: (context) => BudgetBloc(
    RepositoryProvider.of<BudgetRepository>(context),
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