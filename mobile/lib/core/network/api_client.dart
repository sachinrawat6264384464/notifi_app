import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_scheduler_mobile/core/constants/app_constants.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            try {
              final token = await user.getIdToken();
              options.headers['Authorization'] = 'Bearer $token';
            } catch (e) {
              debugPrint('Failed to retrieve token: $e');
            }
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          debugPrint('API Error [${error.response?.statusCode}]: ${error.response?.data}');
          if (error.response?.statusCode == 401) {
            debugPrint('Session expired or unauthorized (401). Triggering sign out.');
            try {
              await FirebaseAuth.instance.signOut();
            } catch (_) {}
          }
          return handler.next(error);
        },
      ),
    );
  }
}
