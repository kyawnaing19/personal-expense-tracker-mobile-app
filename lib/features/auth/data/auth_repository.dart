import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // 👈 debugPrint သုံးနိုင်ရန် ထည့်ပါ
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; 
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class AuthRepository {
  final Dio _dio = DioClient.getInstance();
  final _storage = const FlutterSecureStorage();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '217216164923-2sg4r4ps0dfn974m1ova83514ormn8ig.apps.googleusercontent.com',
  );

  Future<Map<String, dynamic>> googleLogin() async {
    // 1. Google Sign In
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google Sign In cancelled');

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) throw Exception('Failed to get ID token');

    // 2. Laravel API ကို Google token ပို့ (ဒီမှာ fcm_token တွဲမပို့တော့ပါ)
    final response = await _dio.post(
      ApiConstants.googleLogin,
      data: {
        'id_token': idToken,
      },
    );

    // 3. Sanctum token သိမ်း
    final token = response.data['data']['token'];
    await _storage.write(key: 'token', value: token);

    // 4. FCM Token ယူပြီး ချက်ချင်း Laravel ကို သီးသန့် API နဲ့ ပို့ ← ဒီနေရာမှာ
    await _updateFcmToken();

    return response.data['data']['user'];
  }

  // 👈 FCM Token ကို သီးသန့် API နဲ့ လှမ်းပို့ပေးမယ့် Function
  Future<void> _updateFcmToken() async {
    try {
      final fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        await _dio.post(
          ApiConstants.updateFcmToken,
          data: {'fcm_token': fcmToken},
        );
        print("FCM Token updated successfully after login: $fcmToken");
      }
    } catch (e) {
      // FCM token update fail ဖြစ်ရင် login ကို မထိခိုက်အောင် silent fail လုပ်ထားပါတယ်
      debugPrint('FCM token update failed: $e');
    }
  }

  Future<void> logout() async {
    // တစ်ခြား Device တွေနဲ့ မမှားအောင် Logout ထွက်ရင် FCM Token ကို ဖြတ်ပစ်တာ ပိုစိတ်ချရပါတယ်
    try {
      await _firebaseMessaging.deleteToken();
    } catch (e) {
      print("Failed to delete FCM Token on logout: $e");
    }

    await _dio.post(ApiConstants.logout);
    await _storage.delete(key: 'token');
    await _googleSignIn.signOut();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');
    return token != null;
  }
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _dio.get(ApiConstants.me); // 👈 api_constants.dart ထဲက path နာမည်ကို စစ်ပါ
    return response.data['data'];
  }
}