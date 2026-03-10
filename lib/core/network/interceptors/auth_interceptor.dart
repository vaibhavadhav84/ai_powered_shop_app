import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  // Ideally, you'd inject a secure storage instance here to read the token.
  // Example: final SecureStorage _storage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Exclude paths that do not require authentication
    if (!options.path.contains('/login') &&
        !options.path.contains('/register')) {
      try {
        // final token = await _storage.readToken();
        const String token =
            "dummy_jwt_token"; // Replace with actual token retrieval

        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      } catch (e) {
        // Handle token read failure
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized globally here
    if (err.response?.statusCode == 401) {
      // e.g. Trigger token refresh or logout user
    }
    super.onError(err, handler);
  }
}
