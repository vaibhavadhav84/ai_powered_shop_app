import 'package:dio/dio.dart';
import '../../error/failures.dart';

class NetworkExceptionHandler {
  static Failure handleException(dynamic exception) {
    if (exception is DioException) {
      switch (exception.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const ServerFailure('Connection timeout.');
        case DioExceptionType.badResponse:
          final statusCode = exception.response?.statusCode;
          final errorData = exception.response?.data;
          // Example: parse specific error block returned by the server
          return ServerFailure(
            'Bad response: $statusCode. ${errorData?['message'] ?? ''}',
          );
        case DioExceptionType.cancel:
          return const ServerFailure('Request was cancelled.');
        case DioExceptionType.connectionError:
          return const ServerFailure('No internet connection.');
        case DioExceptionType.badCertificate:
          return const ServerFailure('Bad Certificate.');
        case DioExceptionType.unknown:
          return const ServerFailure('An unknown error occurred.');
      }
    }
    return ServerFailure('An unexpected error occurred: $exception');
  }
}
