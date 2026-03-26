import 'dart:convert';

import 'package:dartz_plus/dartz_plus.dart';
import 'package:dio/dio.dart';
import 'package:drifter_buoy/core/constants/app_constants.dart';
import 'package:drifter_buoy/core/error/exception_manager.dart';
import 'package:drifter_buoy/core/error/failure.dart';
import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/core/network/auth_interceptor.dart';
import 'package:drifter_buoy/core/storage/auth_session_store.dart';
import 'package:drifter_buoy/core/network/api_error_response.dart';

class ApiService {
  final Dio _dio;

  ApiService({required String baseUrl, AuthSessionStore? authSessionStore})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: AppConstants.connectTimeout,
          receiveTimeout: AppConstants.receiveTimeout,
          headers: const {'Accept': 'application/json'},
          // Avoid throwing exceptions for 4xx so we can parse & surface
          // backend message/result consistently.
          validateStatus: (status) => status != null && status < 500,
        ),
      ) {
    if (authSessionStore != null) {
      _dio.interceptors.add(
        AuthInterceptor(authSessionStore: authSessionStore),
      );
    }
  }

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
    final requestUrl = path;
    AppLogger.d(
      'API REQUEST\nURL: $requestUrl\nHEADER: ${_safeHeaders(_dio.options.headers)}\nREQUEST PERAMS: ${_formatRequestParams(data)}',
    );
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
          'API RESPONSE\nURL: ${response.requestOptions.uri}\nSTATUS: ${response.statusCode}\nRESPONSE: ${_formatResponseBody(response.data)}\nERROR: ${failure.message}',
        );
        AppLogger.w('${method.name.toUpperCase()} failed: $path');
        return Left(failure);
      }

      final parsedResponse = parser(response.data);
      AppLogger.i(
        'API RESPONSE\nURL: ${response.requestOptions.uri}\nSTATUS: ${response.statusCode}\nRESPONSE: ${_formatResponseBody(response.data)}',
      );
      return Right(parsedResponse);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      AppLogger.e(
        'API ERROR RESPONSE\nURL: ${error.requestOptions.uri}\nSTATUS: $statusCode\nHEADER: ${_safeHeaders(error.requestOptions.headers)}\nREQUEST PERAMS: ${_formatRequestParams(error.requestOptions.data)}\nRESPONSE: ${_formatResponseBody(error.response?.data)}',
        error: error,
      );
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
      // Some backends return HTTP 200 but include `"isSuccess": false`.
      final apiError = ApiErrorResponse.fromJson(response.data);
      if (!apiError.isSuccess) {
        final message = apiError.message.trim();
        return ApiFailure(
          message.isNotEmpty ? message : 'Request failed. Please try again.',
          statusCode,
        );
      }
      return null;
    }

    final message =
        _extractErrorMessage(response.data) ??
        'Request failed. Please try again.';

    return ApiFailure(message, statusCode);
  }

  String? _extractErrorMessage(dynamic responseData) {
    // Backend usually returns this shape:
    // { statusCode, message, result, isSuccess }
    final apiError = ApiErrorResponse.fromJson(responseData);
    final messageText = apiError.message.trim();

    if (messageText.isNotEmpty) {
      // Backend example: message is a generic label, but details are in `result`.
      if (messageText.toLowerCase() == 'unexpected error') {
        if (apiError.result is String &&
            (apiError.result as String).trim().isNotEmpty) {
          return (apiError.result as String).trim();
        }
      }
      return messageText;
    }

    if (apiError.result is String &&
        (apiError.result as String).trim().isNotEmpty) {
      return (apiError.result as String).trim();
    }

    return null;
  }

  Map<String, dynamic> _safeHeaders(Map<String, dynamic>? headers) {
    if (headers == null) {
      return const {};
    }

    return headers.map((key, value) {
      final k = key.toLowerCase();
      if (k.contains('authorization') ||
          k.contains('token') ||
          k.contains('refresh')) {
        if (value is String) {
          return MapEntry(key, _maskToken(value));
        }
      }
      return MapEntry(key, value);
    });
  }

  String _maskToken(String token) {
    if (token.length <= 10) {
      return '***';
    }
    final start = token.substring(0, 6);
    final end = token.substring(token.length - 4);
    return '$start***$end';
  }

  String _formatResponseBody(dynamic body) {
    if (body == null) {
      return 'null';
    }

    if (body is String) {
      return body;
    }

    try {
      return const JsonEncoder.withIndent('  ').convert(body);
    } catch (_) {
      return body.toString();
    }
  }

  String _formatRequestParams(dynamic data) {
    if (data == null) {
      return 'null';
    }

    if (data is FormData) {
      final fieldsMap = <String, dynamic>{};
      for (final entry in data.fields) {
        fieldsMap[entry.key] = entry.value;
      }
      return _formatResponseBody(fieldsMap);
    }

    if (data is Map<String, dynamic>) {
      return _formatResponseBody(data);
    }

    if (data is Map) {
      return _formatResponseBody(data);
    }

    return data.toString();
  }
}

enum HttpMethod { get, post }
