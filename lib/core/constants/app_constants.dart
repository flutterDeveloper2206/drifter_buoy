class AppConstants {
  const AppConstants._();

  static const String appName = 'Drifter Buoys';
  static const String baseUrl = 'https://mobiledbapi.azistaaerospace.com/';
  static const String itemsEndpoint = '/posts';

  static const int defaultUserId = 1;

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Large command catalog payloads can exceed the default receive timeout.
  static const Duration drifterCommandsCatalogReceiveTimeout = Duration(
    seconds: 120,
  );

  static const int drifterCommandsCatalogMaxAttempts = 3;

  static const String genericErrorMessage =
      'Something went wrong. Please try again.';

  static const String bleTimingSettingsPin = '2026';
  static const String masterMpin = '7622';
}
