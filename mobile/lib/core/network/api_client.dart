import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:smart_scheduler_mobile/core/constants/app_constants.dart';
import 'package:smart_scheduler_mobile/core/utils/auth_helper.dart';

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
          final token = await getAuthToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          debugPrint('API Error [${error.response?.statusCode}]: ${error.response?.data}');
          if (error.response?.statusCode == 401) {
            debugPrint('Session expired or unauthorized (401). Clearing token.');
            await removeAuthToken();
          }
          return handler.next(error);
        },
      ),
    );
  }
}
