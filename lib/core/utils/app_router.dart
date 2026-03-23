import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/injection_container.dart';
import 'package:drifter_buoy/core/utils/navigation_service.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoys/general_user_buoys_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoys/general_user_buoys_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_create_password_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_buoys_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_dashboard_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_export_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_forgot_password_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_login_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_buoy_overview_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_map_buoy_details_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_map_filters_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_map_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_map_search_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_splash_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_trajectory_filters_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/pages/general_user_trajectory_view_page.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_overview/general_user_buoy_overview_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_overview/general_user_buoy_overview_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export/general_user_export_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export/general_user_export_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map/general_user_map_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map/general_user_map_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_buoy_details/general_user_map_buoy_details_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_buoy_details/general_user_map_buoy_details_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_filters/general_user_map_filters_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_filters/general_user_map_filters_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/metrics/general_user_metrics_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/metrics/general_user_metrics_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_search/general_user_map_search_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_search/general_user_map_search_event.dart';
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
          return const GeneralUserCreatePasswordPage();
        },
      ),
      GoRoute(
        path: AppRoutes.dashboardPath,
        name: AppRoutes.dashboardName,
        builder: (context, state) {
          return const GeneralUserDashboardPage();
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
          return BlocProvider<GeneralUserMapBloc>(
            create: (_) =>
                sl<GeneralUserMapBloc>()..add(const LoadGeneralUserMap()),
            child: const GeneralUserMapPage(),
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
        path: AppRoutes.mapSearchPath,
        name: AppRoutes.mapSearchName,
        builder: (context, state) {
          return BlocProvider<GeneralUserMapSearchBloc>(
            create: (_) =>
                sl<GeneralUserMapSearchBloc>()
                  ..add(const LoadGeneralUserMapSearch()),
            child: const GeneralUserMapSearchPage(),
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
          return BlocProvider<GeneralUserExportBloc>(
            create: (_) =>
                sl<GeneralUserExportBloc>()..add(const LoadGeneralUserExport()),
            child: const GeneralUserExportPage(),
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
