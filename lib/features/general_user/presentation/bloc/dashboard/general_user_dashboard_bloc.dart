import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/dashboard/general_user_dashboard_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/dashboard/general_user_dashboard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_get_buoy_dashboard.dart';

class GeneralUserDashboardBloc
    extends Bloc<GeneralUserDashboardEvent, GeneralUserDashboardState> {
  GeneralUserDashboardBloc({
    required GeneralUserGetBuoyDashboard getBuoyDashboard,
  })  : _getBuoyDashboard = getBuoyDashboard,
        super(const GeneralUserDashboardInitial()) {
    on<LoadGeneralUserDashboard>(_onLoadGeneralUserDashboard);
  }

  final GeneralUserGetBuoyDashboard _getBuoyDashboard;

  Future<void> _onLoadGeneralUserDashboard(
    LoadGeneralUserDashboard event,
    Emitter<GeneralUserDashboardState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserDashboard event triggered');
    emit(GeneralUserDashboardLoading(isAdmin: event.isAdmin));

    final result = await _getBuoyDashboard.call();

    result.fold(
      (failure) {
        emit(
          GeneralUserDashboardError(
            message: failure.message,
            isAdmin: event.isAdmin,
          ),
        );
      },
      (response) {
        emit(
          GeneralUserDashboardLoaded(
            isAdmin: event.isAdmin,
            data: response.result,
          ),
        );
      },
    );
  }
}
