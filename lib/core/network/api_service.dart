import 'package:dartz_plus/dartz_plus.dart';
import 'package:dio/dio.dart';
import 'package:drifter_buoy/core/constants/app_constants.dart';
import 'package:drifter_buoy/core/error/exception_manager.dart';
import 'package:drifter_buoy/core/error/failure.dart';
import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';

class ApiService {
  final Dio _dio;

  ApiService({required String baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: AppConstants.connectTimeout,
          receiveTimeout: AppConstants.receiveTimeout,
          headers: const {
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
          },
        ),
      );

  ResultFuture<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) parser,
  }) {
    return _request<T>(
      method: HttpMethod.get,
      path: path,
      queryParameters: queryParameters,
      parser: parser,
    );
  }

  ResultFuture<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) parser,
  }) {
    return _request<T>(
      method: HttpMethod.post,
      path: path,
      data: data,
      queryParameters: queryParameters,
      parser: parser,
    );
  }

  ResultFuture<void> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    AppLogger.d('DELETE request: $path');
    try {
      final response = await _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      final failure = _validateResponse(response);
      if (failure != null) {
        AppLogger.w('DELETE failed: $path', error: failure.message);
        return Left(failure);
      }

      AppLogger.i('DELETE success: $path');
      return const Right(null);
    } on DioException catch (error) {
      AppLogger.e('DELETE DioException: $path', error: error);
      return Left(ExceptionManager.mapDioException(error));
    } catch (error) {
      AppLogger.e('DELETE Unknown error: $path', error: error);
      return Left(ExceptionManager.mapException(error));
    }
  }

  ResultFuture<T> _request<T>({
    required HttpMethod method,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) parser,
  }) async {
    AppLogger.d('${method.name.toUpperCase()} request: $path');
    try {
      late final Response<dynamic> response;

      switch (method) {
        case HttpMethod.get:
          response = await _dio.get<dynamic>(
            path,
            queryParameters: queryParameters,
          );
        case HttpMethod.post:
          response = await _dio.post<dynamic>(
            path,
            data: data,
            queryParameters: queryParameters,
          );
      }

      final failure = _validateResponse(response);
      if (failure != null) {
        AppLogger.w(
          '${method.name.toUpperCase()} failed: $path',
          error: failure.message,
        );
        return Left(failure);
      }

      final parsedResponse = parser(response.data);
      AppLogger.i('${method.name.toUpperCase()} success: $path');
      return Right(parsedResponse);
    } on DioException catch (error) {
      AppLogger.e(
        '${method.name.toUpperCase()} DioException: $path',
        error: error,
      );
      return Left(ExceptionManager.mapDioException(error));
    } catch (error) {
      AppLogger.e(
        '${method.name.toUpperCase()} Unknown error: $path',
        error: error,
      );
      return Left(ExceptionManager.mapException(error));
    }
  }

  Failure? _validateResponse(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 0;
    if (statusCode >= 200 && statusCode < 300) {
      return null;
    }

    final message =
        _extractErrorMessage(response.data) ??
        'Request failed. Please try again.';

    return ApiFailure(message, statusCode);
  }

  String? _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final dynamic message = responseData['message'] ?? responseData['error'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }
    return null;
  }
}

enum HttpMethod { get, post }
