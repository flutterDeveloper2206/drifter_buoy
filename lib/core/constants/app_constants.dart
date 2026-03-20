class AppConstants {
  const AppConstants._();

  static const String appName = 'Drifter Buoy';
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String itemsEndpoint = '/posts';

  static const int defaultUserId = 1;

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
}
