import 'package:dio/dio.dart';

import 'package:drifter_buoy/core/storage/auth_session_store.dart';

/// Attaches `Authorization: Bearer <token>` to every API request (if available).
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required AuthSessionStore authSessionStore})
      : _authSessionStore = authSessionStore;

  final AuthSessionStore _authSessionStore;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _authSessionStore.getAccessToken();
    if (token != null && token.trim().isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }
}

