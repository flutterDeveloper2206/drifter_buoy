import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_get_buoy_dashboard.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_get_buoy_map_dashboard.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/dashboard/general_user_dashboard_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/dashboard/general_user_dashboard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserDashboardBloc
    extends Bloc<GeneralUserDashboardEvent, GeneralUserDashboardState> {
  GeneralUserDashboardBloc({
    required GeneralUserGetBuoyDashboard getBuoyDashboard,
    required GeneralUserGetBuoyMapDashboard getBuoyMapDashboard,
  })  : _getBuoyDashboard = getBuoyDashboard,
        _getBuoyMapDashboard = getBuoyMapDashboard,
        super(const GeneralUserDashboardInitial()) {
    on<LoadGeneralUserDashboard>(_onLoadGeneralUserDashboard);
  }

  final GeneralUserGetBuoyDashboard _getBuoyDashboard;
  final GeneralUserGetBuoyMapDashboard _getBuoyMapDashboard;

  Future<void> _onLoadGeneralUserDashboard(
    LoadGeneralUserDashboard event,
    Emitter<GeneralUserDashboardState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserDashboard event triggered');
    emit(GeneralUserDashboardLoading(isAdmin: event.isAdmin));

    final dashboardResult = await _getBuoyDashboard.call();
    final mapResult = await _getBuoyMapDashboard.call();

    dashboardResult.fold(
      (failure) => emit(
        GeneralUserDashboardError(
          message: failure.message,
          isAdmin: event.isAdmin,
        ),
      ),
      (dashboardResponse) {
        mapResult.fold(
          (failure) => emit(
            GeneralUserDashboardError(
              message: failure.message,
              isAdmin: event.isAdmin,
            ),
          ),
          (mapResponse) => emit(
            GeneralUserDashboardLoaded(
              isAdmin: event.isAdmin,
              data: dashboardResponse.result,
              mapData: mapResponse.result,
            ),
          ),
        );
      },
    );
  }
}
