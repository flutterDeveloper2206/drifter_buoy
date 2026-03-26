import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkConnectionChecker {
  NetworkConnectionChecker._();

  static final Connectivity _connectivity = Connectivity();

  static Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  static Future<bool> hasInternetConnection() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    final hasNetwork = connectivityResults.any(
      (r) => r != ConnectivityResult.none,
    );
    if (!hasNetwork) {
      return false;
    }

    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }
}

