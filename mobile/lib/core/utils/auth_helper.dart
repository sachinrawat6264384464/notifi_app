import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_scheduler_mobile/core/constants/app_constants.dart';

const _storage = FlutterSecureStorage();

Future<void> saveAuthToken(String token) async {
  try {
    await _storage.write(key: AppConstants.authTokenKey, value: token);
  } catch (e) {
    debugPrint("Failed to save auth token: $e");
  }
}

Future<String?> getAuthToken() async {
  try {
    return await _storage.read(key: AppConstants.authTokenKey);
  } catch (e) {
    debugPrint("Failed to read auth token: $e");
    return null;
  }
}

Future<void> removeAuthToken() async {
  try {
    await _storage.delete(key: AppConstants.authTokenKey);
  } catch (e) {
    debugPrint("Failed to remove auth token: $e");
  }
}
