import 'dart:async';

import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/core/storage/app_database.dart';
import 'package:drifter_buoy/features/general_user/data/datasources/general_user_self_test_remote_data_source.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/self_test_debug/general_user_self_test_debug_bloc.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_get_buoy_dashboard.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_get_buoy_map_dashboard.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/dashboard/general_user_dashboard_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/dashboard/general_user_dashboard_state.dart';
import 'package:drifter_buoy/core/network/network_connection_checker.dart';
import 'package:drifter_buoy/features/general_user/data/models/user_map_dashboard_get_buoy_dashboard_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserDashboardBloc
    extends Bloc<GeneralUserDashboardEvent, GeneralUserDashboardState> {
  GeneralUserDashboardBloc({
    required GeneralUserGetBuoyDashboard getBuoyDashboard,
    required GeneralUserGetBuoyMapDashboard getBuoyMapDashboard,
    required GeneralUserSelfTestRemoteDataSource remoteDataSource,
  }) : _getBuoyDashboard = getBuoyDashboard,
       _getBuoyMapDashboard = getBuoyMapDashboard,
       _remote = remoteDataSource,
       super(const GeneralUserDashboardInitial()) {
    on<LoadGeneralUserDashboard>(_onLoadGeneralUserDashboard);
  }

  static const Duration _commandSetupOverlayMinDuration = Duration(
    milliseconds: 700,
  );

  final GeneralUserGetBuoyDashboard _getBuoyDashboard;
  final GeneralUserGetBuoyMapDashboard _getBuoyMapDashboard;
  final GeneralUserSelfTestRemoteDataSource _remote;

  Future<void> _onLoadGeneralUserDashboard(
    LoadGeneralUserDashboard event,
    Emitter<GeneralUserDashboardState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserDashboard event triggered');
    final keepCurrentUi =
        event.silent &&
        (state is GeneralUserDashboardLoaded ||
            state is GeneralUserDashboardSyncingCommands);

    if (!keepCurrentUi) {
      emit(GeneralUserDashboardLoading(isAdmin: event.isAdmin));
    }

    final hasInternet = await NetworkConnectionChecker.hasInternetConnection();
    if (!hasInternet) {
      emit(
        GeneralUserDashboardLoaded(
          isAdmin: event.isAdmin,
          isOffline: true,
          data: const UserMapDashboardGetBuoyDashboardResult(
            summary: UserMapDashboardGetBuoyDashboardSummary(
              totalBuoys: 0,
              activeBuoys: 0,
              offlineBuoys: 0,
              batteryLowBuoys: 0,
            ),
            buoyLocations: [],
          ),
          mapData: const [],
        ),
      );
      return;
    }

    final dashboardResult = await _getBuoyDashboard.call();
    final mapResult = await _getBuoyMapDashboard.call();

    await dashboardResult.fold(
      (failure) async => emit(
        GeneralUserDashboardError(
          message: failure.message,
          isAdmin: event.isAdmin,
        ),
      ),
      (dashboardResponse) async {
        await mapResult.fold(
          (failure) async => emit(
            GeneralUserDashboardError(
              message: failure.message,
              isAdmin: event.isAdmin,
            ),
          ),
          (mapResponse) async {
            try {
              final hasCachedCommands = await _hasCachedCommands();
              final loaded = GeneralUserDashboardLoaded(
                isAdmin: event.isAdmin,
                data: dashboardResponse.result,
                mapData: mapResponse.result,
              );

              if (hasCachedCommands) {
                emit(loaded);
                unawaited(_syncCommandsInBackground());
                return;
              }

              emit(
                GeneralUserDashboardSyncingCommands(
                  isAdmin: event.isAdmin,
                  data: dashboardResponse.result,
                  mapData: mapResponse.result,
                ),
              );

              final overlayStarted = DateTime.now();
              await _syncCommandsFromRemote();
              await _waitForMinimumOverlayDuration(overlayStarted);
              emit(loaded);
            } catch (e) {
              AppLogger.e('Error checking/syncing commands: $e');
              emit(
                GeneralUserDashboardLoaded(
                  isAdmin: event.isAdmin,
                  data: dashboardResponse.result,
                  mapData: mapResponse.result,
                ),
              );
            }
          },
        );
      },
    );
  }

  Future<bool> _hasCachedCommands() async {
    try {
      final localCommands = await AppDatabase.instance.getCommands();
      return localCommands.isNotEmpty;
    } catch (e) {
      AppLogger.w('Failed to read cached commands: $e');
      return false;
    }
  }

  Future<void> _syncCommandsInBackground() async {
    try {
      await _syncCommandsFromRemote();
    } catch (e) {
      AppLogger.w('Background command sync failed: $e');
    }
  }

  Future<void> _syncCommandsFromRemote() async {
    final remoteResult = await _remote.getAllDrifterBuoyCommands();
    await remoteResult.fold(
      (remoteFailure) async {
        AppLogger.w('Failed to sync commands: ${remoteFailure.message}');
      },
      (remoteData) async {
        final processed =
            GeneralUserSelfTestDebugBloc.processAndSortApiCommands(
              remoteData.result,
            );
        await AppDatabase.instance.saveCommands(processed);
        AppLogger.i('Synced commands successfully in bloc');
      },
    );
  }

  Future<void> _waitForMinimumOverlayDuration(DateTime started) async {
    final elapsed = DateTime.now().difference(started);
    final remaining = _commandSetupOverlayMinDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
  }
}
