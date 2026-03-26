class AppRoutes {
  const AppRoutes._();

  static const String splashPath = '/';
  static const String splashName = 'splash';

  static const String noInternetPath = '/no-internet';
  static const String noInternetName = 'no-internet';

  static const String loginPath = '/login';
  static const String loginName = 'login';

  static const String forgotPasswordPath = '/forgot-password';
  static const String forgotPasswordName = 'forgot-password';

  static const String createPasswordPath = '/create-password';
  static const String createPasswordName = 'create-password';

  static const String dashboardPath = '/dashboard';
  static const String dashboardName = 'dashboard';

  static const String buoysPath = '/buoys';
  static const String buoysName = 'buoys';

  static const String mapPath = '/map';
  static const String mapName = 'map';

  static const String mapFiltersPath = '/map-filters';
  static const String mapFiltersName = 'map-filters';

  static const String mapBuoyDetailsPath = '/map-buoy-details';
  static const String mapBuoyDetailsName = 'map-buoy-details';

  /// Opens the main map with the in-place search bar (`/map?search=1`).
  static String get mapPathOpenSearch => '$mapPath?search=1';

  static const String buoyOverviewPath = '/buoy-overview';
  static const String buoyOverviewName = 'buoy-overview';

  static const String metricsPath = '/metrics';
  static const String metricsName = 'metrics';

  static const String trajectoryViewPath = '/trajectory-view';
  static const String trajectoryViewName = 'trajectory-view';

  static const String trajectoryFiltersPath = '/trajectory-filters';
  static const String trajectoryFiltersName = 'trajectory-filters';

  static const String exportPath = '/export';
  static const String exportName = 'export';
  static const String exportSelectionPath = '/export-selection';
  static const String exportSelectionName = 'export-selection';
  static const String alertsPath = '/alerts';
  static const String alertsName = 'alerts';
  static const String profilePath = '/profile';
  static const String profileName = 'profile';
  static const String setupPath = '/setup';
  static const String setupName = 'setup';
  static const String setupDetailPath = '/setup-detail';
  static const String setupDetailName = 'setup-detail';
  static const String buoySetupPath = '/buoy-setup';
  static const String buoySetupName = 'buoy-setup';
  static const String selfTestDebugPath = '/self-test-debug';
  static const String selfTestDebugName = 'self-test-debug';

  static const String itemsPath = '/items';
  static const String itemsName = 'items';
}
