import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile/general_user_profile_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile/general_user_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserProfileBloc
    extends Bloc<GeneralUserProfileEvent, GeneralUserProfileState> {
  GeneralUserProfileBloc() : super(const GeneralUserProfileState.initial()) {
    on<LoadGeneralUserProfile>(_onLoadGeneralUserProfile);
    on<RequestGeneralUserLogout>(_onRequestGeneralUserLogout);
    on<ClearGeneralUserProfileMessage>(_onClearGeneralUserProfileMessage);
  }

  Future<void> _onLoadGeneralUserProfile(
    LoadGeneralUserProfile event,
    Emitter<GeneralUserProfileState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserProfile event triggered');
    emit(
      state.copyWith(
        status: GeneralUserProfileStatus.loading,
        message: '',
        logoutSuccess: false,
      ),
    );

    try {
      await Future<void>.delayed(const Duration(milliseconds: 180));
      emit(
        state.copyWith(
          status: GeneralUserProfileStatus.loaded,
          data: const GeneralUserProfileData(
            fullName: 'Parves',
            email: 'abc@example.com',
            role: 'General User',
            phone: '+91 98765 43210',
          ),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: GeneralUserProfileStatus.error,
          message: 'Unable to load profile. Please try again.',
        ),
      );
    }
  }

  Future<void> _onRequestGeneralUserLogout(
    RequestGeneralUserLogout event,
    Emitter<GeneralUserProfileState> emit,
  ) async {
    if (state.isLoggingOut) {
      return;
    }

    emit(
      state.copyWith(
        isLoggingOut: true,
        message: '',
        logoutSuccess: false,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 450));
    emit(
      state.copyWith(
        isLoggingOut: false,
        logoutSuccess: true,
        message: 'Logged out successfully.',
      ),
    );
  }

  void _onClearGeneralUserProfileMessage(
    ClearGeneralUserProfileMessage event,
    Emitter<GeneralUserProfileState> emit,
  ) {
    emit(state.copyWith(message: '', logoutSuccess: false));
  }
}
