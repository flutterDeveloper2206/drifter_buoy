import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/injection_container.dart';
import 'package:drifter_buoy/core/utils/navigation_service.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoys/general_user_buoys_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoys/general_user_buoys_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/alerts/general_user_alerts_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/alerts/general_user_alerts_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/create_password/general_user_create_password_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_create_password_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_alerts_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/dashboard/general_user_dashboard_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/dashboard/general_user_dashboard_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile/general_user_profile_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile/general_user_profile_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_profile_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_setup_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_setup_detail_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_detail/general_user_setup_detail_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_detail/general_user_setup_detail_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_buoy_setup_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_setup/general_user_buoy_setup_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_setup/general_user_buoy_setup_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_self_test_debug_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/self_test_debug/general_user_self_test_debug_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/self_test_debug/general_user_self_test_debug_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_buoys_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_dashboard_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_export_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_export_selection_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_forgot_password_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_login_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_buoy_overview_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_map_buoy_details_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_map_filters_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_map_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_no_internet_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_splash_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_trajectory_filters_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_trajectory_view_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_overview/general_user_buoy_overview_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_overview/general_user_buoy_overview_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export/general_user_export_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export/general_user_export_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export_selection/general_user_export_selection_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export_selection/general_user_export_selection_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map/general_user_map_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map/general_user_map_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_buoy_details/general_user_map_buoy_details_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_buoy_details/general_user_map_buoy_details_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_filters/general_user_map_filters_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_filters/general_user_map_filters_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/metrics/general_user_metrics_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/metrics/general_user_metrics_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_view/general_user_trajectory_view_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_view/general_user_trajectory_view_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_filters/general_user_trajectory_filters_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_filters/general_user_trajectory_filters_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_metrics_page.dart';
import 'package:drifter_buoy/features/sample_feature/presentation/bloc/items_bloc.dart';
import 'package:drifter_buoy/features/sample_feature/presentation/bloc/items_event.dart';
import 'package:drifter_buoy/features/sample_feature/presentation/pages/items_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: NavigationService.navigatorKey,
    initialLocation: AppRoutes.splashPath,
    routes: [
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splashName,
        builder: (context, state) {
          return const GeneralUserSplashPage();
        },
      ),
      GoRoute(
        path: AppRoutes.noInternetPath,
        name: AppRoutes.noInternetName,
        builder: (context, state) {
          return const GeneralUserNoInternetPage();
        },
      ),
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.loginName,
        builder: (context, state) {
          return const GeneralUserLoginPage();
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPasswordPath,
        name: AppRoutes.forgotPasswordName,
        builder: (context, state) {
          return const GeneralUserForgotPasswordPage();
        },
      ),
      GoRoute(
        path: AppRoutes.createPasswordPath,
        name: AppRoutes.createPasswordName,
        builder: (context, state) {
          return BlocProvider<GeneralUserCreatePasswordBloc>(
            create: (_) => sl<GeneralUserCreatePasswordBloc>(),
            child: const GeneralUserCreatePasswordPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.dashboardPath,
        name: AppRoutes.dashboardName,
        builder: (context, state) {
          final extra = state.extra;
          final isAdmin = extra is bool ? extra : false;
          return BlocProvider<GeneralUserDashboardBloc>(
            create: (_) =>
                sl<GeneralUserDashboardBloc>()
                  ..add(LoadGeneralUserDashboard(isAdmin: isAdmin)),
            child: const GeneralUserDashboardPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.buoysPath,
        name: AppRoutes.buoysName,
        builder: (context, state) {
          return BlocProvider<GeneralUserBuoysBloc>(
            create: (_) =>
                sl<GeneralUserBuoysBloc>()..add(const LoadGeneralUserBuoys()),
            child: const GeneralUserBuoysPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.mapPath,
        name: AppRoutes.mapName,
        builder: (context, state) {
          final openSearch = state.uri.queryParameters['search'] == '1';
          return BlocProvider<GeneralUserMapBloc>(
            create: (_) =>
                sl<GeneralUserMapBloc>()..add(const LoadGeneralUserMap()),
            child: GeneralUserMapPage(initialSearchOpen: openSearch),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.mapFiltersPath,
        name: AppRoutes.mapFiltersName,
        builder: (context, state) {
          return BlocProvider<GeneralUserMapFiltersBloc>(
            create: (_) =>
                sl<GeneralUserMapFiltersBloc>()
                  ..add(const LoadGeneralUserMapFilters()),
            child: const GeneralUserMapFiltersPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.mapBuoyDetailsPath,
        name: AppRoutes.mapBuoyDetailsName,
        builder: (context, state) {
          return BlocProvider<GeneralUserMapBuoyDetailsBloc>(
            create: (_) =>
                sl<GeneralUserMapBuoyDetailsBloc>()
                  ..add(const LoadGeneralUserMapBuoyDetails()),
            child: const GeneralUserMapBuoyDetailsPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.buoyOverviewPath,
        name: AppRoutes.buoyOverviewName,
        builder: (context, state) {
          final extra = state.extra;
          final buoyId = extra is String && extra.trim().isNotEmpty
              ? extra.trim()
              : 'DB-01';

          return BlocProvider<GeneralUserBuoyOverviewBloc>(
            create: (_) =>
                sl<GeneralUserBuoyOverviewBloc>()
                  ..add(LoadGeneralUserBuoyOverview(buoyId: buoyId)),
            child: const GeneralUserBuoyOverviewPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.metricsPath,
        name: AppRoutes.metricsName,
        builder: (context, state) {
          final extra = state.extra;
          final buoyId = extra is String && extra.trim().isNotEmpty
              ? extra.trim()
              : 'DB-01';

          return BlocProvider<GeneralUserMetricsBloc>(
            create: (_) =>
                sl<GeneralUserMetricsBloc>()
                  ..add(LoadGeneralUserMetrics(buoyId: buoyId)),
            child: const GeneralUserMetricsPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.trajectoryViewPath,
        name: AppRoutes.trajectoryViewName,
        builder: (context, state) {
          final extra = state.extra;
          final buoyId = extra is String && extra.trim().isNotEmpty
              ? extra.trim()
              : 'DB-01';

          return BlocProvider<GeneralUserTrajectoryViewBloc>(
            create: (_) =>
                sl<GeneralUserTrajectoryViewBloc>()
                  ..add(LoadGeneralUserTrajectoryView(buoyId: buoyId)),
            child: const GeneralUserTrajectoryViewPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.trajectoryFiltersPath,
        name: AppRoutes.trajectoryFiltersName,
        builder: (context, state) {
          final extra = state.extra;
          final buoyId = extra is String && extra.trim().isNotEmpty
              ? extra.trim()
              : 'DB-01';

          return BlocProvider<GeneralUserTrajectoryFiltersBloc>(
            create: (_) =>
                sl<GeneralUserTrajectoryFiltersBloc>()
                  ..add(LoadGeneralUserTrajectoryFilters(buoyId: buoyId)),
            child: const GeneralUserTrajectoryFiltersPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.exportPath,
        name: AppRoutes.exportName,
        builder: (context, state) {
          final extra = state.extra;
          final selectedBuoyCount = extra is int && extra > 0 ? extra : 0;

          return BlocProvider<GeneralUserExportBloc>(
            create: (_) =>
                sl<GeneralUserExportBloc>()
                  ..add(
                    LoadGeneralUserExport(
                      selectedBuoyCount: selectedBuoyCount,
                    ),
                  ),
            child: const GeneralUserExportPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.exportSelectionPath,
        name: AppRoutes.exportSelectionName,
        builder: (context, state) {
          return BlocProvider<GeneralUserExportSelectionBloc>(
            create: (_) =>
                sl<GeneralUserExportSelectionBloc>()
                  ..add(const LoadGeneralUserExportSelection()),
            child: const GeneralUserExportSelectionPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.alertsPath,
        name: AppRoutes.alertsName,
        builder: (context, state) {
          return BlocProvider<GeneralUserAlertsBloc>(
            create: (_) =>
                sl<GeneralUserAlertsBloc>()..add(const LoadGeneralUserAlerts()),
            child: const GeneralUserAlertsPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.profilePath,
        name: AppRoutes.profileName,
        builder: (context, state) {
          return BlocProvider<GeneralUserProfileBloc>(
            create: (_) =>
                sl<GeneralUserProfileBloc>()..add(const LoadGeneralUserProfile()),
            child: const GeneralUserProfilePage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.setupPath,
        name: AppRoutes.setupName,
        builder: (context, state) {
          return const GeneralUserSetupPage();
        },
      ),
      GoRoute(
        path: AppRoutes.setupDetailPath,
        name: AppRoutes.setupDetailName,
        builder: (context, state) {
          return BlocProvider<GeneralUserSetupDetailBloc>(
            create: (_) =>
                sl<GeneralUserSetupDetailBloc>()
                  ..add(const LoadGeneralUserSetupDetail()),
            child: const GeneralUserSetupDetailPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.buoySetupPath,
        name: AppRoutes.buoySetupName,
        builder: (context, state) {
          return BlocProvider<GeneralUserBuoySetupBloc>(
            create: (_) =>
                sl<GeneralUserBuoySetupBloc>()..add(const LoadGeneralUserBuoySetup()),
            child: const GeneralUserBuoySetupPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.selfTestDebugPath,
        name: AppRoutes.selfTestDebugName,
        builder: (context, state) {
          return BlocProvider<GeneralUserSelfTestDebugBloc>(
            create: (_) =>
                sl<GeneralUserSelfTestDebugBloc>()
                  ..add(const LoadGeneralUserSelfTestDebug()),
            child: const GeneralUserSelfTestDebugPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.itemsPath,
        name: AppRoutes.itemsName,
        builder: (context, state) {
          return BlocProvider<ItemsBloc>(
            create: (_) => sl<ItemsBloc>()..add(const FetchItems()),
            child: const ItemsPage(),
          );
        },
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(child: Text(state.error?.toString() ?? 'Route not found')),
      );
    },
  );
}
