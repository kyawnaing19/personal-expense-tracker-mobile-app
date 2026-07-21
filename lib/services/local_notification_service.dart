// import 'dart:convert';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class LocalNotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
//   static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//   static Future<void> initialize() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//     );

//     await _notificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//          debugPrint("🔔 Notification TAPPED! payload = ${response.payload}");
//         if (response.payload != null) {
//           try {
//             final Map<String, dynamic> data = json.decode(response.payload!);
//             debugPrint("🔔 Decoded data = $data");
//             handleRouting(data); 
//           } catch (e) {
//             debugPrint("Payload : $e");
//           }
//         }
//         else {
//         debugPrint("⚠️ payload က null ဖြစ်နေတယ်");
//       }
//       },
//     );

//      await _notificationsPlugin
//       .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//       ?.requestNotificationsPermission();
//   }

//   static Future<void> display(RemoteMessage message) async {
//     const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
//       'expense_tracker_channel',
//       'Expense Notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//       sound: RawResourceAndroidNotificationSound('notification_sound'), 
//       playSound: true,             
//       enableVibration: true,
//     );

//     const NotificationDetails notificationDetails = NotificationDetails(
//       android: androidNotificationDetails,
//     );
//     await _notificationsPlugin.show(
//       DateTime.now().hashCode, 
//       message.notification?.title,
//       message.notification?.body,
//       notificationDetails,
//       payload: json.encode(message.data), 
//     );
//   }

//     static void handleRouting(Map<String, dynamic> data) {
//       debugPrint("🚦 handleRouting called with: $data");
//     if (data.isEmpty) return;

//     final String? type = data['type'];
//     debugPrint("🚦 type = $type");

//     switch (type) {
      
//       case 'member_invited':
//       case 'member_joined':
//       case 'member_joined_via_code':
//         final String? groupId = data['group_id']?.toString();
//         navigatorKey.currentState?.pushNamed('/group_detail', arguments: {
//           'group_id': groupId,
//           'type': type,
//         });
//         break;

//       case 'group_expense_created':
//         final String? expenseId = data['expense_id']?.toString();
//         final String? expenseGroupId = data['group_id']?.toString();
//         final String? amountOwed = data['amount_owed']?.toString();
//         navigatorKey.currentState?.pushNamed('/group_expense_detail', arguments: {
//           'expense_id': expenseId,
//           'group_id': expenseGroupId,
//           'amount_owed': amountOwed,
//         });
//         break;

//       case 'payment_claim':
// case 'payment_confirmed':
// case 'payment_rejected':
//   final isClaimAgainstMe = type == 'payment_claim';
//   navigatorKey.currentState?.pushNamed('/debt_requests', arguments: {
//     'initial_role': isClaimAgainstMe ? 'payer' : 'claimant',
//   });
//   break;

//     case 'budget_exceeded':
// case 'budget_warning':
//   final String? categoryId = data['category_id']?.toString();
//   navigatorKey.currentState?.pushNamed('/budget_overview', arguments: {
//     'highlight_category_id': categoryId,
//     'type': type,
//   });
//   break;

//       default:
//         debugPrint("သတ်မှတ်မထားသော နိုတီအမျိုးအစားဖြစ်နေပါသည်: $type");
//         break;
//     }
//   }
  
// }



import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Keep channel id/name/sound in one place so initialize() and display()
  // always agree with each other.
  static const String _channelId = 'expense_tracker_channel';
  static const String _channelName = 'Expense Notifications';
  static const String _soundResourceName = 'notification_sound'; // android/app/src/main/res/raw/notification_sound.mp3

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("🔔 Notification TAPPED! payload = ${response.payload}");
        if (response.payload != null) {
          try {
            final Map<String, dynamic> data = json.decode(response.payload!);
            debugPrint("🔔 Decoded data = $data");
            handleRouting(data);
          } catch (e) {
            debugPrint("Payload : $e");
          }
        } else {
          debugPrint("⚠️ payload က null ဖြစ်နေတယ်");
        }
      },
    );

    // ---- IMPORTANT FIX ----
    // Register (create) the Android notification channel up-front, with the
    // custom sound attached to it, instead of waiting for the first call to
    // `.show()`. On Android, a channel's sound is locked in the moment the
    // channel is first created — if the channel gets auto-created by the OS
    // first (e.g. from a background/terminated-state FCM push before the app
    // has ever called `.show()`), it will silently fall back to the default
    // sound and there is no way to change it afterwards without the user
    // clearing app data or reinstalling.
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Notifications for expenses, groups, budgets and payments',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(_soundResourceName),
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> display(RemoteMessage message) async {
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound(_soundResourceName),
      playSound: true,
      enableVibration: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await _notificationsPlugin.show(
      DateTime.now().hashCode,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: json.encode(message.data),
    );
  }

  static void handleRouting(Map<String, dynamic> data) {
    debugPrint("🚦 handleRouting called with: $data");
    if (data.isEmpty) return;

    final String? type = data['type'];
    debugPrint("🚦 type = $type");

    switch (type) {
      case 'member_invited':
      case 'member_joined':
      case 'member_joined_via_code':
        final String? groupId = data['group_id']?.toString();
        navigatorKey.currentState?.pushNamed('/group_detail', arguments: {
          'group_id': groupId,
          'type': type,
        });
        break;

      case 'group_expense_created':
        final String? expenseId = data['expense_id']?.toString();
        final String? expenseGroupId = data['group_id']?.toString();
        final String? amountOwed = data['amount_owed']?.toString();
        navigatorKey.currentState?.pushNamed('/group_expense_detail', arguments: {
          'expense_id': expenseId,
          'group_id': expenseGroupId,
          'amount_owed': amountOwed,
        });
        break;

      case 'payment_claim':
      case 'payment_confirmed':
      case 'payment_rejected':
        final isClaimAgainstMe = type == 'payment_claim';
        navigatorKey.currentState?.pushNamed('/debt_requests', arguments: {
          'initial_role': isClaimAgainstMe ? 'payer' : 'claimant',
        });
        break;

      case 'budget_exceeded':
      case 'budget_warning':
        final String? categoryId = data['category_id']?.toString();
        navigatorKey.currentState?.pushNamed('/budget_overview', arguments: {
          'highlight_category_id': categoryId,
          'type': type,
        });
        break;

      default:
        debugPrint("သတ်မှတ်မထားသော နိုတီအမျိုးအစားဖြစ်နေပါသည်: $type");
        break;
    }
  }
}
