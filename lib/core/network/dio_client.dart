import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

class DioClient {
  late final Dio _dio;

  // Example configuration
  static const String baseUrl = 'https://fakestoreapi.com/products';
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectionTimeout,
        receiveTimeout: receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 1. Auth Interceptor (adds token, handles 401s)
    _dio.interceptors.add(AuthInterceptor());

    // 2. Retry Interceptor (attempts to retry failed network requests due to timeout/bad connections)
    _dio.interceptors.add(RetryInterceptor(dio: _dio));

    // 3. Logging Interceptor (Print requests/responses cleanly only in debug mode)
    if (kDebugMode) {
      _dio.interceptors.add(LoggingInterceptor());
    }
  }

  Dio get dio => _dio;

  // Convenient generic wrappers could be added here
  // e.g. Future<Response> get(String path, {Map<String, dynamic>? queryParameters})
}
