import 'package:drifter_buoy/core/constants/app_constants.dart';

class ApiEndpoints {
  const ApiEndpoints._();

  static String get _base => AppConstants.baseUrl;

  static String get loginUrl => '${_base}api/UserAuthenticate/Login';

  static String get requestVerificationCodeUrl =>
      '${_base}api/UserAuthenticate/RequestVerificationCode';

  static String get verifyVerificationCodeUrl =>
      '${_base}api/UserAuthenticate/VerifyCode';

  static String get resetPasswordUrl =>
      '${_base}api/UserAuthenticate/ResetPassword';

  static String get changeCurrentPasswordUrl =>
      '${_base}api/UserAuthenticate/ChangeCurrentPassword';

  static String get getBuoyDashboardUrl =>
      '${_base}api/User/UserMapDashboard/GetBuoyDashboard';

  static String get getBuoyMapDashboardUrl =>
      '${_base}api/User/UserMapDashboard/GetBuoyMapDashboard';

  static String get updateUserProfileUrl =>
      '${_base}api/Admin/User/UpdateUserProfile';

  static String get getAllBuoysStatusForExportUrl =>
      '${_base}api/Report/Report/GetAllBuoysStatusForExport';

  static String get getAllBuoysDataOverviewViewUrl =>
      '${_base}api/User/UserViewBuoyDashboard/GetAllBuoysDataOverviewView';

  static String get getAllBuoysStatusUrl =>
      '${_base}api/User/UserViewBuoyDashboard/GetAllBuoysStatus';

  static String get getBuoyDataOverviewUrl =>
      '${_base}api/User/UserViewBuoyDashboard/GetBuoyDataOverview';

  static String get getBuoyMetricsUrl =>
      '${_base}api/User/UserViewBuoyDashboard/GetBuoyMetrics';

  static String get getBuoyTrajectoryViewUrl =>
      '${_base}api/User/UserViewBuoyDashboard/GetBuoyTrajectoryView';

  static String get getBuoyDistanceReportForExportUrl =>
      '${_base}api/Report/Report/GetBuoyDistanceReportForExport';

  static String get getBuoyDataReportForExportUrl =>
      '${_base}api/Report/Report/GetBuoyDataReportForExport';

  static String get registerDeviceTokenUrl =>
      '${_base}api/admin/DeviceToken/register';

  static String get getAllNotificationsUrl =>
      '${_base}api/admin/Notification/GetAllNotifications';

  static String get getAllDrifterBuoyCommandsUrl =>
      '${_base}api/Admin/Command/GetAllDrifterBuoyCommands';

  static String get createNewDrifterBuoyUrl =>
      '${_base}api/Admin/Station/CreateNewDrifterBuoy';
}
