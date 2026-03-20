import 'package:dio/dio.dart';
import 'package:drifter_buoy/core/constants/app_constants.dart';
import 'package:drifter_buoy/core/error/app_exceptions.dart';
import 'package:drifter_buoy/core/error/failure.dart';

class ExceptionManager {
  const ExceptionManager._();

  static Failure mapException(Object error) {
    if (error is Failure) {
      return error;
    }

    if (error is DioException) {
      return mapDioException(error);
    }

    if (error is AppException) {
      return _mapAppException(error);
    }

    if (error is FormatException || error is TypeError) {
      return const ParsingFailure();
    }

    return const UnknownFailure(AppConstants.genericErrorMessage);
  }

  static Failure mapDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        final message =
            _extractErrorMessage(exception.response?.data) ??
            'Request failed. Please try again.';
        return ApiFailure(message, statusCode);
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return UnknownFailure(
          exception.message ?? AppConstants.genericErrorMessage,
        );
    }
  }

  static Failure _mapAppException(AppException exception) {
    if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    }

    if (exception is ApiException) {
      return ApiFailure(exception.message, exception.statusCode);
    }

    if (exception is ParsingException) {
      return ParsingFailure(exception.message);
    }

    return UnknownFailure(exception.message);
  }

  static String? _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final dynamic message = responseData['message'] ?? responseData['error'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }
    return null;
  }
}
