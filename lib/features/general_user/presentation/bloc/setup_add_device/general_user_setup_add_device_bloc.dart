import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_add_device/general_user_setup_add_device_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/setup_add_device/general_user_setup_add_device_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserSetupAddDeviceBloc extends Bloc<
  GeneralUserSetupAddDeviceEvent,
  GeneralUserSetupAddDeviceState
> {
  GeneralUserSetupAddDeviceBloc()
    : super(const GeneralUserSetupAddDeviceState.initial()) {
    on<LoadGeneralUserSetupAddDevice>(_onLoadGeneralUserSetupAddDevice);
    on<SelectGeneralUserNearbyDevice>(_onSelectGeneralUserNearbyDevice);
  }

  Future<void> _onLoadGeneralUserSetupAddDevice(
    LoadGeneralUserSetupAddDevice event,
    Emitter<GeneralUserSetupAddDeviceState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserSetupAddDevice event triggered');
    emit(
      state.copyWith(
        status: GeneralUserSetupAddDeviceStatus.loading,
        message: '',
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 180));
    emit(
      state.copyWith(
        status: GeneralUserSetupAddDeviceStatus.loaded,
        nearbyDevices: const ['Buoy 02', 'Device 02', 'iPhone 15'],
      ),
    );
  }

  void _onSelectGeneralUserNearbyDevice(
    SelectGeneralUserNearbyDevice event,
    Emitter<GeneralUserSetupAddDeviceState> emit,
  ) {
    emit(
      state.copyWith(
        selectedDevice: event.deviceName,
      ),
    );
  }
}
