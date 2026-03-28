import 'package:drifter_buoy/core/constants/app_constants.dart';
import 'package:drifter_buoy/core/device/login_device_info_service.dart';
import 'package:drifter_buoy/core/storage/auth_session_store.dart';
import 'package:drifter_buoy/core/network/api_service.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoys/general_user_buoys_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/alerts/general_user_alerts_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_overview/general_user_buoy_overview_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/dashboard/general_user_dashboard_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export/general_user_export_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export_selection/general_user_export_selection_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/login/general_user_login_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/forgot_password/general_user_forgot_password_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/create_password/general_user_create_password_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile/general_user_profile_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile_update/general_user_update_profile_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map/general_user_map_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_buoy_details/general_user_map_buoy_details_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_filters/general_user_map_filters_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/metrics/general_user_metrics_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_filters/general_user_trajectory_filters_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_view/general_user_trajectory_view_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_detail/general_user_setup_detail_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_setup/general_user_buoy_setup_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/self_test_debug/general_user_self_test_debug_bloc.dart';
import 'package:drifter_buoy/features/general_user/data/datasources/general_user_auth_remote_data_source.dart';
import 'package:drifter_buoy/features/general_user/data/datasources/general_user_profile_remote_data_source.dart';
import 'package:drifter_buoy/features/general_user/data/datasources/general_user_dashboard_remote_data_source.dart';
import 'package:drifter_buoy/features/general_user/data/datasources/general_user_export_selection_remote_data_source.dart';
import 'package:drifter_buoy/features/general_user/data/datasources/general_user_buoys_remote_data_source.dart';
import 'package:drifter_buoy/features/general_user/data/repositories/general_user_auth_repository_impl.dart';
import 'package:drifter_buoy/features/general_user/data/repositories/general_user_profile_repository_impl.dart';
import 'package:drifter_buoy/features/general_user/data/repositories/general_user_dashboard_repository_impl.dart';
import 'package:drifter_buoy/features/general_user/data/repositories/general_user_export_selection_repository_impl.dart';
import 'package:drifter_buoy/features/general_user/data/repositories/general_user_buoys_repository_impl.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_auth_repository.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_profile_repository.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_dashboard_repository.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_export_selection_repository.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_buoys_repository.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_login.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_request_verification_code.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_verify_verification_code.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_reset_password.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_get_buoy_dashboard.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_get_buoy_map_dashboard.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_get_all_buoys_status_for_export.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_get_all_buoys_data_overview_view.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_update_user_profile.dart';
import 'package:drifter_buoy/features/sample_feature/data/datasources/item_remote_data_source.dart';
import 'package:drifter_buoy/features/sample_feature/data/repositories/item_repository_impl.dart';
import 'package:drifter_buoy/features/sample_feature/domain/repositories/item_repository.dart';
import 'package:drifter_buoy/features/sample_feature/domain/usecases/add_item.dart';
import 'package:drifter_buoy/features/sample_feature/domain/usecases/delete_item.dart';
import 'package:drifter_buoy/features/sample_feature/domain/usecases/get_items.dart';
import 'package:drifter_buoy/features/sample_feature/presentation/bloc/items_bloc.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  if (!sl.isRegistered<AuthSessionStore>()) {
    sl.registerLazySingleton<AuthSessionStore>(
      () => AuthSessionStore(),
    );
  }

  if (!sl.isRegistered<ApiService>()) {
    sl.registerLazySingleton<ApiService>(
      () => ApiService(
        baseUrl: AppConstants.baseUrl,
        authSessionStore: sl<AuthSessionStore>(),
      ),
    );
  }

  if (!sl.isRegistered<LoginDeviceInfoService>()) {
    sl.registerLazySingleton<LoginDeviceInfoService>(
      () => LoginDeviceInfoService(),
    );
  }

  if (!sl.isRegistered<GeneralUserAuthRemoteDataSource>()) {
    sl.registerLazySingleton<GeneralUserAuthRemoteDataSource>(
      () => GeneralUserAuthRemoteDataSource(apiService: sl()),
    );
  }

  if (!sl.isRegistered<GeneralUserAuthRepository>()) {
    sl.registerLazySingleton<GeneralUserAuthRepository>(
      () => GeneralUserAuthRepositoryImpl(remoteDataSource: sl()),
    );
  }

  if (!sl.isRegistered<GeneralUserLogin>()) {
    sl.registerLazySingleton<GeneralUserLogin>(
      () => GeneralUserLogin(
        repository: sl(),
        deviceInfoService: sl(),
        authSessionStore: sl(),
      ),
    );
  }

  if (!sl.isRegistered<GeneralUserLoginBloc>()) {
    sl.registerFactory<GeneralUserLoginBloc>(
      () => GeneralUserLoginBloc(login: sl()),
    );
  }

  if (!sl.isRegistered<GeneralUserRequestVerificationCode>()) {
    sl.registerLazySingleton<GeneralUserRequestVerificationCode>(
      () => GeneralUserRequestVerificationCode(sl()),
    );
  }

  if (!sl.isRegistered<GeneralUserVerifyVerificationCode>()) {
    sl.registerLazySingleton<GeneralUserVerifyVerificationCode>(
      () => GeneralUserVerifyVerificationCode(
        repository: sl(),
        authSessionStore: sl(),
      ),
    );
  }

  if (!sl.isRegistered<GeneralUserForgotPasswordBloc>()) {
    sl.registerFactory<GeneralUserForgotPasswordBloc>(
      () => GeneralUserForgotPasswordBloc(
        requestCode: sl(),
        verifyCode: sl(),
      ),
    );
  }

  if (!sl.isRegistered<GeneralUserResetPassword>()) {
    sl.registerLazySingleton<GeneralUserResetPassword>(
      () => GeneralUserResetPassword(
        repository: sl(),
        authSessionStore: sl(),
      ),
    );
  }

  if (!sl.isRegistered<GeneralUserCreatePasswordBloc>()) {
    sl.registerFactory<GeneralUserCreatePasswordBloc>(
      () => GeneralUserCreatePasswordBloc(
        resetPassword: sl(),
      ),
    );
  }

  if (!sl.isRegistered<ItemRemoteDataSource>()) {
    sl.registerLazySingleton<ItemRemoteDataSource>(
      () => ItemRemoteDataSourceImpl(apiService: sl()),
    );
  }

  if (!sl.isRegistered<ItemRepository>()) {
    sl.registerLazySingleton<ItemRepository>(
      () => ItemRepositoryImpl(remoteDataSource: sl()),
    );
  }

  if (!sl.isRegistered<GetItems>()) {
    sl.registerLazySingleton<GetItems>(() => GetItems(sl()));
  }
  if (!sl.isRegistered<AddItem>()) {
    sl.registerLazySingleton<AddItem>(() => AddItem(sl()));
  }
  if (!sl.isRegistered<DeleteItem>()) {
    sl.registerLazySingleton<DeleteItem>(() => DeleteItem(sl()));
  }

  if (!sl.isRegistered<ItemsBloc>()) {
    sl.registerFactory<ItemsBloc>(
      () => ItemsBloc(getItems: sl(), addItem: sl(), deleteItem: sl()),
    );
  }

  if (!sl.isRegistered<GeneralUserMapBloc>()) {
    sl.registerFactory<GeneralUserMapBloc>(() => GeneralUserMapBloc());
  }

  if (!sl.isRegistered<GeneralUserMapFiltersBloc>()) {
    sl.registerFactory<GeneralUserMapFiltersBloc>(
      () => GeneralUserMapFiltersBloc(),
    );
  }

  if (!sl.isRegistered<GeneralUserMapBuoyDetailsBloc>()) {
    sl.registerFactory<GeneralUserMapBuoyDetailsBloc>(
      () => GeneralUserMapBuoyDetailsBloc(),
    );
  }

  if (!sl.isRegistered<GeneralUserBuoyOverviewBloc>()) {
    sl.registerFactory<GeneralUserBuoyOverviewBloc>(
      () => GeneralUserBuoyOverviewBloc(),
    );
  }

  if (!sl.isRegistered<GeneralUserTrajectoryViewBloc>()) {
    sl.registerFactory<GeneralUserTrajectoryViewBloc>(
      () => GeneralUserTrajectoryViewBloc(),
    );
  }

  if (!sl.isRegistered<GeneralUserTrajectoryFiltersBloc>()) {
    sl.registerFactory<GeneralUserTrajectoryFiltersBloc>(
      () => GeneralUserTrajectoryFiltersBloc(),
    );
  }

  if (!sl.isRegistered<GeneralUserExportBloc>()) {
    sl.registerFactory<GeneralUserExportBloc>(() => GeneralUserExportBloc());
  }

  if (!sl.isRegistered<GeneralUserExportSelectionRemoteDataSource>()) {
    sl.registerLazySingleton<GeneralUserExportSelectionRemoteDataSource>(
      () => GeneralUserExportSelectionRemoteDataSource(apiService: sl()),
    );
  }

  if (!sl.isRegistered<GeneralUserExportSelectionRepository>()) {
    sl.registerLazySingleton<GeneralUserExportSelectionRepository>(
      () => GeneralUserExportSelectionRepositoryImpl(
        remoteDataSource: sl(),
      ),
    );
  }

  if (!sl.isRegistered<GeneralUserGetAllBuoysStatusForExport>()) {
    sl.registerLazySingleton<GeneralUserGetAllBuoysStatusForExport>(
      () => GeneralUserGetAllBuoysStatusForExport(repository: sl()),
    );
  }

  // Re-register factory to avoid stale closures during hot-reload/dev cycles.
  if (sl.isRegistered<GeneralUserExportSelectionBloc>()) {
    sl.unregister<GeneralUserExportSelectionBloc>();
  }

  sl.registerFactory<GeneralUserExportSelectionBloc>(
    () => GeneralUserExportSelectionBloc(
      getAllBuoysStatusForExport: sl(),
    ),
  );

  if (!sl.isRegistered<GeneralUserAlertsBloc>()) {
    sl.registerFactory<GeneralUserAlertsBloc>(() => GeneralUserAlertsBloc());
  }

  if (!sl.isRegistered<GeneralUserProfileBloc>()) {
    sl.registerFactory<GeneralUserProfileBloc>(
      () => GeneralUserProfileBloc(authSessionStore: sl()),
    );
  }

  if (!sl.isRegistered<GeneralUserDashboardBloc>()) {
    if (!sl.isRegistered<GeneralUserDashboardRemoteDataSource>()) {
      sl.registerLazySingleton<GeneralUserDashboardRemoteDataSource>(
        () => GeneralUserDashboardRemoteDataSource(apiService: sl()),
      );
    }

    if (!sl.isRegistered<GeneralUserDashboardRepository>()) {
      sl.registerLazySingleton<GeneralUserDashboardRepository>(
        () => GeneralUserDashboardRepositoryImpl(
          remoteDataSource: sl(),
        ),
      );
    }

    if (!sl.isRegistered<GeneralUserGetBuoyDashboard>()) {
      sl.registerLazySingleton<GeneralUserGetBuoyDashboard>(
        () => GeneralUserGetBuoyDashboard(repository: sl()),
      );
    }

    if (!sl.isRegistered<GeneralUserGetBuoyMapDashboard>()) {
      sl.registerLazySingleton<GeneralUserGetBuoyMapDashboard>(
        () => GeneralUserGetBuoyMapDashboard(repository: sl()),
      );
    }

    sl.registerFactory<GeneralUserDashboardBloc>(
      () => GeneralUserDashboardBloc(
        getBuoyDashboard: sl(),
        getBuoyMapDashboard: sl(),
      ),
    );
  }

  // Profile update (Admin/User/UpdateUserProfile)
  if (!sl.isRegistered<GeneralUserProfileRemoteDataSource>()) {
    sl.registerLazySingleton<GeneralUserProfileRemoteDataSource>(
      () => GeneralUserProfileRemoteDataSource(apiService: sl()),
    );
  }

  if (!sl.isRegistered<GeneralUserProfileRepository>()) {
    sl.registerLazySingleton<GeneralUserProfileRepository>(
      () => GeneralUserProfileRepositoryImpl(
        remoteDataSource: sl(),
      ),
    );
  }

  if (!sl.isRegistered<GeneralUserUpdateUserProfile>()) {
    sl.registerLazySingleton<GeneralUserUpdateUserProfile>(
      () => GeneralUserUpdateUserProfile(
        repository: sl(),
        authSessionStore: sl(),
      ),
    );
  }

  if (!sl.isRegistered<GeneralUserUpdateProfileBloc>()) {
    sl.registerFactory<GeneralUserUpdateProfileBloc>(
      () => GeneralUserUpdateProfileBloc(
        updateUserProfile: sl(),
      ),
    );
  }

  if (!sl.isRegistered<GeneralUserBuoysRemoteDataSource>()) {
    sl.registerLazySingleton<GeneralUserBuoysRemoteDataSource>(
      () => GeneralUserBuoysRemoteDataSource(apiService: sl()),
    );
  }

  if (!sl.isRegistered<GeneralUserBuoysRepository>()) {
    sl.registerLazySingleton<GeneralUserBuoysRepository>(
      () => GeneralUserBuoysRepositoryImpl(remoteDataSource: sl()),
    );
  }

  if (!sl.isRegistered<GeneralUserGetAllBuoysDataOverviewView>()) {
    sl.registerLazySingleton<GeneralUserGetAllBuoysDataOverviewView>(
      () => GeneralUserGetAllBuoysDataOverviewView(repository: sl()),
    );
  }

  if (sl.isRegistered<GeneralUserBuoysBloc>()) {
    sl.unregister<GeneralUserBuoysBloc>();
  }

  sl.registerFactory<GeneralUserBuoysBloc>(
    () => GeneralUserBuoysBloc(
      getAllBuoysDataOverviewView: sl(),
    ),
  );

  if (!sl.isRegistered<GeneralUserMetricsBloc>()) {
    sl.registerFactory<GeneralUserMetricsBloc>(() => GeneralUserMetricsBloc());
  }

  if (!sl.isRegistered<GeneralUserSetupDetailBloc>()) {
    sl.registerFactory<GeneralUserSetupDetailBloc>(
      () => GeneralUserSetupDetailBloc(),
    );
  }

  if (!sl.isRegistered<GeneralUserBuoySetupBloc>()) {
    sl.registerFactory<GeneralUserBuoySetupBloc>(() => GeneralUserBuoySetupBloc());
  }

  if (!sl.isRegistered<GeneralUserSelfTestDebugBloc>()) {
    sl.registerFactory<GeneralUserSelfTestDebugBloc>(
      () => GeneralUserSelfTestDebugBloc(),
    );
  }
}
