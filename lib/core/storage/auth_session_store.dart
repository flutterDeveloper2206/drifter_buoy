import 'dart:convert';

import 'package:drifter_buoy/features/general_user/data/models/user_authenticate_login_response.dart';
import 'package:drifter_buoy/core/storage/app_pref_keys.dart';
import 'package:drifter_buoy/core/storage/app_prefs.dart';

/// Stores the latest authenticated session locally for:
/// - attaching token to API requests
/// - populating Profile screen data
class AuthSessionStore {
  AuthSessionStore({AppPrefs? appPrefs}) : _appPrefs = appPrefs ?? AppPrefs();

  final AppPrefs _appPrefs;

  Future<void> saveLoginResponse(UserAuthenticateLoginResponse response) async {
    final loginJson = jsonEncode(response.toJson());
    await _appPrefs.setString(AppPrefKeys.authLoginResponse, loginJson);
    await _appPrefs.setString(AppPrefKeys.authAccessToken, response.result.token);
    await _appPrefs.setString(
      AppPrefKeys.authRefreshToken,
      response.result.refreshToken,
    );
  }

  Future<UserAuthenticateLoginResponse?> getLoginResponse() async {
    final raw = await _appPrefs.getString(AppPrefKeys.authLoginResponse);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    return UserAuthenticateLoginResponse.fromJson(decoded);
  }

  Future<String?> getAccessToken() async {
    return _appPrefs.getString(AppPrefKeys.authAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return _appPrefs.getString(AppPrefKeys.authRefreshToken);
  }

  Future<void> saveResetToken(String resetToken) async {
    await _appPrefs.setString(AppPrefKeys.authResetToken, resetToken);
  }

  Future<String?> getResetToken() async {
    return _appPrefs.getString(AppPrefKeys.authResetToken);
  }

  Future<void> clear() async {
    await _appPrefs.remove(AppPrefKeys.authLoginResponse);
    await _appPrefs.remove(AppPrefKeys.authAccessToken);
    await _appPrefs.remove(AppPrefKeys.authRefreshToken);
    await _appPrefs.remove(AppPrefKeys.authResetToken);
  }
}

