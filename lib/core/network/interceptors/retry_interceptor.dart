import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int maxRetries;
  final List<Duration> retryDelays;

  RetryInterceptor({
    required Dio dio,
    this.maxRetries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
    ],
  }) : _dio = dio;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    int retryCount = extra['retryCount'] ?? 0;

    if (_shouldRetry(err) && retryCount < maxRetries) {
      retryCount++;
      extra['retryCount'] = retryCount;

      final delay = retryDelays.length >= retryCount
          ? retryDelays[retryCount - 1]
          : retryDelays.last;

      log(
        'Retrying operation. Attempt $retryCount after ${delay.inSeconds} seconds',
      );

      await Future.delayed(delay);

      try {
        final options = err.requestOptions;

        final response = await _dio.request(
          options.path,
          queryParameters: options.queryParameters,
          data: options.data,
          options: Options(
            method: options.method,
            headers: options.headers,
            extra: options.extra,
            responseType: options.responseType,
            contentType: options.contentType,
            receiveTimeout: options.receiveTimeout,
            sendTimeout: options.sendTimeout,
          ),
          onReceiveProgress: options.onReceiveProgress,
          onSendProgress: options.onSendProgress,
          cancelToken: options.cancelToken, // Careful: Token might be cancelled
        );

        return handler.resolve(response);
      } on DioException catch (e) {
        return super.onError(e, handler); // Continue failure loop
      } catch (e) {
        // Shouldn't happen but just in case
      }
    }

    super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.unknown) {
      return true;
    }

    if (err.response != null) {
      final statusCode = err.response!.statusCode;
      if (statusCode != null && (statusCode >= 500 && statusCode < 600)) {
        return true;
      }
    }

    return false;
  }
}
