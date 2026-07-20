import 'package:dio/dio.dart';
import 'package:expense_tracker/cache-first/cache/local_cache_service.dart';
import 'package:expense_tracker/core/services/current_user_service..dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/storage/secure_storage.dart';

class AuthRepository {
  final Dio _dio = DioClient.getInstance();
  final _storage = AppSecureStorage.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static const String _cachedUserKey = 'current_user';

  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '217216164923-2sg4r4ps0dfn974m1ova83514ormn8ig.apps.googleusercontent.com',
  );

  Future<Map<String, dynamic>> googleLogin() async {
  final googleUser = await _googleSignIn.signIn();
  if (googleUser == null) throw Exception('Google Sign In cancelled');

  final googleAuth = await googleUser.authentication;
  final idToken = googleAuth.idToken;
  if (idToken == null) throw Exception('Failed to get ID token');

  final response = await _dio.post(
    ApiConstants.googleLogin,
    data: {'id_token': idToken},
  );

  final token = response.data['data']['token'];
  final user = response.data['data']['user'];

  await _storage.write(key: 'token', value: token);
  await LocalCacheService.instance.save(_cachedUserKey, user);  

  await _updateFcmToken();
  return user;
}

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
     
      debugPrint('FCM token update failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseMessaging.deleteToken();
    } catch (e) {
      debugPrint("Failed to delete FCM Token on logout: $e");
    }

    try {
      await _dio.post(ApiConstants.logout);
    } catch (e) {
      debugPrint("Server logout request failed: $e");
    }

    await _storage.deleteAll();

    await LocalCacheService.instance.clearAll();

    CurrentUserService.clear();

    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect(); 
    } catch (e) {
      debugPrint("Google Sign Out/Disconnect failed: $e");
    }
  }
 
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');
    return token != null;
  }
 
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _dio.get(ApiConstants.me);
    final user = response.data['data'];
 
    await LocalCacheService.instance.save(_cachedUserKey, user);
 
    return user;
  }
 
  Future<Map<String, dynamic>?> getCachedUser() async {
    final cached = await LocalCacheService.instance.read(_cachedUserKey);
    return cached as Map<String, dynamic>?;
  }
 
  Future<void> clearSession() async {
    await _storage.delete(key: 'token');
    await LocalCacheService.instance.clearKey(_cachedUserKey);
  }
}
 
