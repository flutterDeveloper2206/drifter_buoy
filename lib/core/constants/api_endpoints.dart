class ApiEndpoints {
  const ApiEndpoints._();
  // http://4.213.34.231:5025/api/

  static const String loginUrl =
      'https://mobiledbapi.azistaaerospace.com/api/UserAuthenticate/Login';

  static const String requestVerificationCodeUrl =
      'https://mobiledbapi.azistaaerospace.com/api/UserAuthenticate/RequestVerificationCode';

  static const String verifyVerificationCodeUrl =
      'https://mobiledbapi.azistaaerospace.com/api/UserAuthenticate/VerifyCode';

  static const String resetPasswordUrl =
      'https://mobiledbapi.azistaaerospace.com/api/UserAuthenticate/ResetPassword';

  static const String getBuoyDashboardUrl =
      'https://mobiledbapi.azistaaerospace.com/api/User/UserMapDashboard/GetBuoyDashboard';

  static const String getBuoyMapDashboardUrl =
      'https://mobiledbapi.azistaaerospace.com/api/User/UserMapDashboard/GetBuoyMapDashboard';

  static const String updateUserProfileUrl =
      'https://mobiledbapi.azistaaerospace.com/api/Admin/User/UpdateUserProfile';

  static const String getAllBuoysStatusForExportUrl =
      'https://mobiledbapi.azistaaerospace.com/api/Report/Report/GetAllBuoysStatusForExport';

  static const String getAllBuoysDataOverviewViewUrl =
      'https://mobiledbapi.azistaaerospace.com/api/User/UserViewBuoyDashboard/GetAllBuoysDataOverviewView';

  static const String getAllBuoysStatusUrl =
      'https://mobiledbapi.azistaaerospace.com/api/User/UserViewBuoyDashboard/GetAllBuoysStatus';

  static const String getBuoyDataOverviewUrl =
      'https://mobiledbapi.azistaaerospace.com/api/User/UserViewBuoyDashboard/GetBuoyDataOverview';

  static const String getBuoyMetricsUrl =
      'https://mobiledbapi.azistaaerospace.com/api/User/UserViewBuoyDashboard/GetBuoyMetrics';

  static const String getBuoyTrajectoryViewUrl =
      'https://mobiledbapi.azistaaerospace.com/api/User/UserViewBuoyDashboard/GetBuoyTrajectoryView';

  static const String getBuoyDistanceReportForExportUrl =
      'https://mobiledbapi.azistaaerospace.com/api/Report/Report/GetBuoyDistanceReportForExport';

  static const String getBuoyDataReportForExportUrl =
      'https://mobiledbapi.azistaaerospace.com/api/Report/Report/GetBuoyDataReportForExport';

  static const String registerDeviceTokenUrl =
      'https://mobiledbapi.azistaaerospace.com/api/admin/DeviceToken/register';

  static const String getAllNotificationsUrl =
      'https://mobiledbapi.azistaaerospace.com/api/admin/Notification/GetAllNotifications';

  static const String getAllDrifterBuoyCommandsUrl =
      'https://mobiledbapi.azistaaerospace.com/api/Admin/Command/GetAllDrifterBuoyCommands';

  static const String createNewDrifterBuoyUrl =
      'https://mobiledbapi.azistaaerospace.com/api/Admin/Station/CreateNewDrifterBuoy';
}
