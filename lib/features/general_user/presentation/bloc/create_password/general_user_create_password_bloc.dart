import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_reset_password.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/create_password/general_user_create_password_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/create_password/general_user_create_password_state.dart';

class GeneralUserCreatePasswordBloc extends Bloc<
    GeneralUserCreatePasswordEvent, GeneralUserCreatePasswordState> {
  GeneralUserCreatePasswordBloc({
    required GeneralUserResetPassword resetPassword,
  })  : _resetPassword = resetPassword,
        super(const GeneralUserCreatePasswordInitial()) {
    on<GeneralUserCreatePasswordRequested>(_onRequested);
  }

  final GeneralUserResetPassword _resetPassword;

  Future<void> _onRequested(
    GeneralUserCreatePasswordRequested event,
    Emitter<GeneralUserCreatePasswordState> emit,
  ) async {
    AppLogger.i('GeneralUserCreatePasswordRequested');
    emit(const GeneralUserCreatePasswordLoading());

    final result = await _resetPassword.call(
      newPassword: event.newPassword,
      confirmPassword: event.confirmPassword,
    );

    result.fold(
      (failure) {
        emit(GeneralUserCreatePasswordError(message: failure.message));
      },
      (response) {
        final msg = response.result.isNotEmpty
            ? response.result
            : (response.message.isNotEmpty ? response.message : 'Success');
        emit(GeneralUserCreatePasswordSuccess(message: msg));
      },
    );
  }
}

