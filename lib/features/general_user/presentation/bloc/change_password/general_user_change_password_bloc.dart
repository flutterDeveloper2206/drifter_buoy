import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_change_current_password.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/change_password/general_user_change_password_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/change_password/general_user_change_password_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GeneralUserChangePasswordBloc
    extends Bloc<GeneralUserChangePasswordEvent, GeneralUserChangePasswordState> {
  GeneralUserChangePasswordBloc({
    required GeneralUserChangeCurrentPassword changeCurrentPassword,
  })  : _changeCurrentPassword = changeCurrentPassword,
        super(const GeneralUserChangePasswordInitial()) {
    on<ChangeGeneralUserPasswordRequested>(_onChangeRequested);
  }

  final GeneralUserChangeCurrentPassword _changeCurrentPassword;

  Future<void> _onChangeRequested(
    ChangeGeneralUserPasswordRequested event,
    Emitter<GeneralUserChangePasswordState> emit,
  ) async {
    AppLogger.i('ChangeGeneralUserPasswordRequested');
    emit(const GeneralUserChangePasswordLoading());

    final result = await _changeCurrentPassword.call(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
      confirmPassword: event.confirmPassword,
    );

    result.fold(
      (failure) {
        emit(GeneralUserChangePasswordError(message: failure.message));
      },
      (response) {
        final messageText = response.result.trim().isNotEmpty
            ? response.result.trim()
            : (response.message.trim().isNotEmpty
                ? response.message.trim()
                : 'Password updated successfully.');
        emit(GeneralUserChangePasswordSuccess(message: messageText));
      },
    );
  }
}
