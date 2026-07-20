import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSecureStorage {
  static const FlutterSecureStorage instance = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
}