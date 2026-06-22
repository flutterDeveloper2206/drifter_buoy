import 'package:drifter_buoy/core/constants/app_constants.dart';

class ApiEndpoints {
  const ApiEndpoints._();

  static const String _base = AppConstants.baseUrl;

  static const String loginUrl = '$_base/api/UserAuthenticate/Login';

  static const String requestVerificationCodeUrl =
      '$_base/api/UserAuthenticate/RequestVerificationCode';

  static const String verifyVerificationCodeUrl =
      '$_base/api/UserAuthenticate/VerifyCode';

  static const String resetPasswordUrl =
      '$_base/api/UserAuthenticate/ResetPassword';

  static const String getBuoyDashboardUrl =
      '$_base/api/User/UserMapDashboard/GetBuoyDashboard';

  static const String getBuoyMapDashboardUrl =
      '$_base/api/User/UserMapDashboard/GetBuoyMapDashboard';

  static const String updateUserProfileUrl =
      '$_base/api/Admin/User/UpdateUserProfile';

  static const String getAllBuoysStatusForExportUrl =
      '$_base/api/Report/Report/GetAllBuoysStatusForExport';

  static const String getAllBuoysDataOverviewViewUrl =
      '$_base/api/User/UserViewBuoyDashboard/GetAllBuoysDataOverviewView';

  static const String getAllBuoysStatusUrl =
      '$_base/api/User/UserViewBuoyDashboard/GetAllBuoysStatus';

  static const String getBuoyDataOverviewUrl =
      '$_base/api/User/UserViewBuoyDashboard/GetBuoyDataOverview';

  static const String getBuoyMetricsUrl =
      '$_base/api/User/UserViewBuoyDashboard/GetBuoyMetrics';

  static const String getBuoyTrajectoryViewUrl =
      '$_base/api/User/UserViewBuoyDashboard/GetBuoyTrajectoryView';

  static const String getBuoyDistanceReportForExportUrl =
      '$_base/api/Report/Report/GetBuoyDistanceReportForExport';

  static const String getBuoyDataReportForExportUrl =
      '$_base/api/Report/Report/GetBuoyDataReportForExport';

  static const String registerDeviceTokenUrl =
      '$_base/api/admin/DeviceToken/register';

  static const String getAllNotificationsUrl =
      '$_base/api/admin/Notification/GetAllNotifications';

  static const String getAllDrifterBuoyCommandsUrl =
      '$_base/api/Admin/Command/GetAllDrifterBuoyCommands';

  static const String createNewDrifterBuoyUrl =
      '$_base/api/User/UserBuoySetup/CreateNewDrifterBuoy';
}
