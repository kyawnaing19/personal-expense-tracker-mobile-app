import 'package:expense_tracker/core/connectivity/connectivity_cubit.dart';
import 'package:expense_tracker/features/auth/data/analytics_repository.dart';
import 'package:expense_tracker/features/auth/data/expense_repository.dart';
import 'package:expense_tracker/features/auth/data/expense_split_repository.dart';
import 'package:expense_tracker/features/auth/data/group_repository.dart';
import 'package:expense_tracker/features/auth/data/recurring_transaction_repository.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/analytics_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/group_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/recurring_transaction_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/screens/MainNavigationScreen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/budget_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/debt_requests_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/group_detail_loader_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/group_expense_detail_loader_screen.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/connectivity_listener.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/offline_banner.dart';
import 'package:expense_tracker/models/settlement_request_model.dart';
import 'package:expense_tracker/services/local_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:expense_tracker/core/network/dio_client.dart'; 
import 'package:expense_tracker/core/constants/api_constants.dart'; 
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
import 'package:expense_tracker/core/storage/secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await LocalNotificationService.initialize();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      LocalNotificationService.display(message);
      print("Foreground မှာ Notification ရောက်လာပါတယ်: ${message.notification?.title}");
    }
  });

  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted notification permission: ${settings.authorizationStatus}');

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final sanctumToken = await AppSecureStorage.instance.read(key: 'token');

      if (sanctumToken != null) {
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
  
  await Hive.initFlutter();
  await Hive.openBox('categories_cache');

  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

  runApp(MyApp(initialMessage: initialMessage));
}

class MyApp extends StatelessWidget {
  final RemoteMessage? initialMessage;
  
  const MyApp({Key? key, this.initialMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (context) => AuthRepository()),
        RepositoryProvider<CategoryRepository>(create: (context) => CategoryRepository()),
        RepositoryProvider<TransactionRepository>(create: (context) => TransactionRepository()), 
        RepositoryProvider<AnalyticsRepository>(create: (context) => AnalyticsRepository()),
        RepositoryProvider<BudgetRepository>(
          create: (context) => BudgetRepository(RepositoryProvider.of<CategoryRepository>(context)),
        ),
        RepositoryProvider<GroupRepository>(create: (context) => GroupRepository()),
        RepositoryProvider<ExpenseSplitRepository>(create: (context) => ExpenseSplitRepository()),
        RepositoryProvider<ExpenseRepository>(create: (context) => ExpenseRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ConnectivityCubit>(create: (context) => ConnectivityCubit()),
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(RepositoryProvider.of<AuthRepository>(context))..add(CheckAuthStatus()),
          ),
          BlocProvider<CategoryBloc>(
            create: (context) => CategoryBloc(RepositoryProvider.of<CategoryRepository>(context))..add(LoadCategories()), 
          ),
          BlocProvider<TransactionBloc>(create: (context) => TransactionBloc(RepositoryProvider.of<TransactionRepository>(context))), 
          BlocProvider<AnalyticsBloc>(create: (context) => AnalyticsBloc(RepositoryProvider.of<AnalyticsRepository>(context))),
          BlocProvider<BudgetBloc>(create: (context) => BudgetBloc(RepositoryProvider.of<BudgetRepository>(context))),
          BlocProvider<RecurringTransactionBloc>(create: (_) => RecurringTransactionBloc(RecurringTransactionRepository())),
          BlocProvider<GroupBloc>(create: (context) => GroupBloc(RepositoryProvider.of<GroupRepository>(context))),
        ],
        child: MaterialApp(
          title: 'Expense Tracker',
          debugShowCheckedModeBanner: false,
          
          navigatorKey: LocalNotificationService.navigatorKey, 
          
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
          ),
          
        onGenerateRoute: (settings) {
  switch (settings.name) {
    case '/group_detail':
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => GroupDetailLoaderScreen(
          groupId: args?['group_id'] as String?,
        ),
      );

    case '/group_expense_detail':
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => GroupExpenseDetailLoaderScreen(
          expenseId: args?['expense_id'] as String?,
           groupId: args?['group_id'] as String?,
        ),
      );

    case '/debt_requests':
      final args = settings.arguments as Map<String, dynamic>?;
      final roleStr = args?['initial_role'] as String?;
      return MaterialPageRoute(
        builder: (_) => DebtRequestsScreen(
          initialRole: roleStr == 'claimant'
              ? SettlementRequestRole.claimant
              : SettlementRequestRole.payer,
        ),
      );

    case '/budget_overview':
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => BudgetScreen( 
          highlightCategoryId: args?['highlight_category_id'] as String?,
        ),
      );

    default:
      return null;
  }
},

          builder: (context, child) {
            return ConnectivityListener(
              child: OfflineBanner(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          home: MainNavigationWrapper(initialMessage: initialMessage),
        ),
      ),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  final RemoteMessage? initialMessage;
  const MainNavigationWrapper({Key? key, this.initialMessage}) : super(key: key);

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data.isNotEmpty) {
        LocalNotificationService.handleRouting(message.data);
      }
    });

    if (widget.initialMessage != null) {
      Future.delayed(const Duration(seconds: 1), () {
        if (widget.initialMessage!.data.isNotEmpty) {
          LocalNotificationService.handleRouting(widget.initialMessage!.data);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
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
    );
  }
}

