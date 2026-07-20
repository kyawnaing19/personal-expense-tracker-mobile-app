// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// class LocalNotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

//   static Future<void> initialize() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//     );

//     await _notificationsPlugin.initialize(initializationSettings);
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
//     );
//   }
// }


import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // App တစ်ခုလုံးအတွက် BuildContext မလိုဘဲ သုံးနိုင်မည့် Global Navigator Key
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // နိုတီကို သုံးစွဲသူက နှိပ်လိုက်သည့်အခါ (Foreground / Background တွင် ရှိနေစဉ်) အလုပ်လုပ်မည့်စနစ်
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
         debugPrint("🔔 Notification TAPPED! payload = ${response.payload}");
        if (response.payload != null) {
          try {
            final Map<String, dynamic> data = json.decode(response.payload!);
            debugPrint("🔔 Decoded data = $data");
            handleRouting(data); // လမ်းကြောင်းခွဲပေးသည့် စနစ်သို့ ဒေတာပို့ခြင်း
          } catch (e) {
            debugPrint("Payload 解析错误: $e");
          }
        }
        else {
        debugPrint("⚠️ payload က null ဖြစ်နေတယ်"); // 👈 ထပ်ထည့်
      }
      },
    );

     await _notificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
  }

  static Future<void> display(RemoteMessage message) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'expense_tracker_channel',
      'Expense Notifications',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('notification_sound'), 
      playSound: true,             
      enableVibration: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    // Firebase မှ ပါလာသော ဒေတာ (Map) ကို စာသား (String) အဖြစ်ပြောင်းပြီး payload ထဲသို့ ထည့်သွင်းခြင်း
    await _notificationsPlugin.show(
      DateTime.now().hashCode, 
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: json.encode(message.data), 
    );
  }

  // မျက်နှာပြင် လမ်းကြောင်းခွဲပေးသည့် ဘုံ (Shared) လုပ်ဆောင်ချက်
  // ဤနေရာတွင် Payload ထဲက 'screen' နာမည်နှင့် Flutter ရဲ့ Named Route တို့ကို ချိတ်ဆက်ပေးထားခြင်းဖြစ်သည်
    static void handleRouting(Map<String, dynamic> data) {
      debugPrint("🚦 handleRouting called with: $data");
    if (data.isEmpty) return;

    // Backend မှ ပို့လိုက်သော အဓိက Key ဖြစ်သည့် 'type' ကို ဖတ်ခြင်း
    final String? type = data['type'];
    debugPrint("🚦 type = $type");

    switch (type) {
      
      // ၁။ အုပ်စုနှင့် ပတ်သက်သော နိုတီများ (Group Related Notifications)
      case 'member_invited':
      case 'member_joined':
      case 'member_joined_via_code':
        final String? groupId = data['group_id']?.toString();
        // /group_detail စခရင်သို့ သွားမည်
        navigatorKey.currentState?.pushNamed('/group_detail', arguments: {
          'group_id': groupId,
          'type': type,
        });
        break;

      // ၂။ အုပ်စုတွင်း အသုံးစရိတ်အသစ် တက်လာသည့် နိုတီ
      case 'group_expense_created':
        final String? expenseId = data['expense_id']?.toString();
        final String? expenseGroupId = data['group_id']?.toString();
        final String? amountOwed = data['amount_owed']?.toString();
        // /group_expense_detail သို့မဟုတ် /expense_detail စခရင်သို့ ဒေတာအစုံလိုက် ပို့မည်
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

