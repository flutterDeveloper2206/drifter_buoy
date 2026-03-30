class ApiEndpoints {
  const ApiEndpoints._();

  static const String loginUrl =
      'http://4.213.34.231:5025/api/UserAuthenticate/Login';

  static const String requestVerificationCodeUrl =
      'http://4.213.34.231:5025/api/UserAuthenticate/RequestVerificationCode';

  static const String verifyVerificationCodeUrl =
      'http://4.213.34.231:5025/api/UserAuthenticate/VerifyCode';

  static const String resetPasswordUrl =
      'http://4.213.34.231:5025/api/UserAuthenticate/ResetPassword';

  static const String getBuoyDashboardUrl =
      'http://4.213.34.231:5025/api/User/UserMapDashboard/GetBuoyDashboard';

  static const String getBuoyMapDashboardUrl =
      'http://4.213.34.231:5025/api/User/UserMapDashboard/GetBuoyMapDashboard';

  static const String updateUserProfileUrl =
      'http://4.213.34.231:5025/api/Admin/User/UpdateUserProfile';

  static const String getAllBuoysStatusForExportUrl =
      'http://4.213.34.231:5025/api/Report/Report/GetAllBuoysStatusForExport';

  static const String getAllBuoysDataOverviewViewUrl =
      'http://4.213.34.231:5025/api/User/UserViewBuoyDashboard/GetAllBuoysDataOverviewView';

  static const String getAllBuoysStatusUrl =
      'http://4.213.34.231:5025/api/User/UserViewBuoyDashboard/GetAllBuoysStatus';

  static const String getBuoyDataOverviewUrl =
      'http://4.213.34.231:5025/api/User/UserViewBuoyDashboard/GetBuoyDataOverview';

  static const String getBuoyMetricsUrl =
      'http://4.213.34.231:5025/api/User/UserViewBuoyDashboard/GetBuoyMetrics';

  static const String getBuoyTrajectoryViewUrl =
      'http://4.213.34.231:5025/api/User/UserViewBuoyDashboard/GetBuoyTrajectoryView';

  static const String getBuoyDistanceReportForExportUrl =
      'http://4.213.34.231:5025/api/Report/Report/GetBuoyDistanceReportForExport';

  static const String getBuoyDataReportForExportUrl =
      'http://4.213.34.231:5025/api/Report/Report/GetBuoyDataReportForExport';
}
