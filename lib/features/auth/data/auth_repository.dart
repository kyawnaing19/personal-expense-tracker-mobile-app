import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class AuthRepository {
  final Dio _dio = DioClient.getInstance();
  final _storage = const FlutterSecureStorage();


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
    await _storage.write(key: 'token', value: token);

    return response.data['data']['user'];
  }

  Future<void> logout() async {
    await _dio.post(ApiConstants.logout);
    await _storage.delete(key: 'token');
    await _googleSignIn.signOut();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');
    return token != null;
  }
}