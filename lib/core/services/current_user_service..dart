import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import '../constants/api_constants.dart';

class CurrentUserService {
  static String? _cachedId;
  static String? _cachedEmail;

  static Future<Map<String, String?>> getCurrentUser(
      {bool forceRefresh = false}) async {
    if (!forceRefresh && (_cachedId != null || _cachedEmail != null)) {
      return {'id': _cachedId, 'email': _cachedEmail};
    }
    try {
      final dio = DioClient.getInstance();
      final response = await dio.get(ApiConstants.me);
      final raw = response.data;
      final data = (raw is Map && raw['data'] != null) ? raw['data'] : raw;
      if (data is Map) {
        _cachedId = data['id']?.toString();
        _cachedEmail = data['email']?.toString();
      }
    } on DioException catch (_) {
    }
    return {'id': _cachedId, 'email': _cachedEmail};
  }

  static void clear() {
    _cachedId = null;
    _cachedEmail = null;
  }
}
