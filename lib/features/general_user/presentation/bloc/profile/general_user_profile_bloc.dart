import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/core/storage/auth_session_store.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile/general_user_profile_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile/general_user_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserProfileBloc
    extends Bloc<GeneralUserProfileEvent, GeneralUserProfileState> {
  GeneralUserProfileBloc({required AuthSessionStore authSessionStore})
      : _authSessionStore = authSessionStore,
        super(const GeneralUserProfileInitial()) {
    on<LoadGeneralUserProfile>(_onLoadGeneralUserProfile);
    on<RequestGeneralUserLogout>(_onRequestGeneralUserLogout);
    on<ClearGeneralUserProfileMessage>(_onClearGeneralUserProfileMessage);
  }

  final AuthSessionStore _authSessionStore;

  Future<void> _onLoadGeneralUserProfile(
    LoadGeneralUserProfile event,
    Emitter<GeneralUserProfileState> emit,
  ) async {
    AppLogger.i('LoadGeneralUserProfile event triggered');
    emit(const GeneralUserProfileLoading());

    try {
      await Future<void>.delayed(const Duration(milliseconds: 120));

      final loginResponse = await _authSessionStore.getLoginResponse();
      if (loginResponse == null) {
        emit(const GeneralUserProfileError(message: 'Please log in again.'));
        return;
      }

      final result = loginResponse.result;
      emit(
        GeneralUserProfileLoaded(
          data: GeneralUserProfileData(
            userId: result.userId,
            firstName: result.firstName,
            middleName: result.middleName,
            lastName: result.lastName,
            fullName: result.fullName,
            email: result.emailAddress,
            role: result.roleName,
            phone: result.mobileNumber,
          ),
          isLoggingOut: false,
          logoutSuccess: false,
          message: '',
        ),
      );
    } catch (_) {
      emit(
        const GeneralUserProfileError(
          message: 'Unable to load profile. Please try again.',
        ),
      );
    }
  }

  Future<void> _onRequestGeneralUserLogout(
    RequestGeneralUserLogout event,
    Emitter<GeneralUserProfileState> emit,
  ) async {
    if (state is GeneralUserProfileLoaded && state.isLoggingOut) {
      return;
    }

    if (state is! GeneralUserProfileLoaded) {
      return;
    }

    emit(
      GeneralUserProfileLoaded(
        data: state.data!,
        isLoggingOut: true,
        logoutSuccess: false,
        message: '',
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 250));
    await _authSessionStore.clear();
    emit(
      GeneralUserProfileLoaded(
        data: state.data!,
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
    if (state is GeneralUserProfileLoaded) {
      emit(
        GeneralUserProfileLoaded(
          data: state.data!,
          isLoggingOut: state.isLoggingOut,
          logoutSuccess: false,
          message: '',
        ),
      );
      return;
    }

    if (state is GeneralUserProfileError) {
      emit(const GeneralUserProfileInitial());
      return;
    }

    emit(const GeneralUserProfileInitial());
  }
}
