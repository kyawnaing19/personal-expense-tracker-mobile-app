import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Error တက်တဲ့နေရာကို ဒီလိုပြင်ကြည့်ပါ
    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> display(RemoteMessage message) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'expense_tracker_channel',
      'Expense Notifications',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('notification_sound'), // အသံဖိုင်နာမည် (extension မလို)
      playSound: true,             // အသံဖွင့်ရန်
      enableVibration: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    // ID ကို int အဖြစ်သေချာသတ်မှတ်ပါ
    await _notificationsPlugin.show(
      DateTime.now().hashCode, 
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
    );
  }
}