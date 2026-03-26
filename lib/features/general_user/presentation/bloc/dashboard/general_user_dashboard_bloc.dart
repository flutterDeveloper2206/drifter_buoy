import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/dashboard/general_user_dashboard_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/dashboard/general_user_dashboard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserDashboardBloc
    extends Bloc<GeneralUserDashboardEvent, GeneralUserDashboardState> {
  GeneralUserDashboardBloc() : super(const GeneralUserDashboardInitial()) {
    on<LoadGeneralUserDashboard>(_onLoadGeneralUserDashboard);
  }

  Future<void> _onLoadGeneralUserDashboard(
    LoadGeneralUserDashboard event,
    Emitter<GeneralUserDashboardState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserDashboard event triggered');
    emit(GeneralUserDashboardLoading(isAdmin: event.isAdmin));

    await Future<void>.delayed(const Duration(milliseconds: 120));
    emit(GeneralUserDashboardLoaded(isAdmin: event.isAdmin));
  }
}
