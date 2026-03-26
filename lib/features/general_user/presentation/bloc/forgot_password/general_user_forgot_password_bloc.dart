import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_request_verification_code.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_verify_verification_code.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/forgot_password/general_user_forgot_password_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/forgot_password/general_user_forgot_password_state.dart';

class GeneralUserForgotPasswordBloc extends Bloc<
    GeneralUserForgotPasswordEvent, GeneralUserForgotPasswordState> {
  GeneralUserForgotPasswordBloc({
    required GeneralUserRequestVerificationCode requestCode,
    required GeneralUserVerifyVerificationCode verifyCode,
  })  : _requestCode = requestCode,
        _verifyCode = verifyCode,
        super(const GeneralUserForgotPasswordInitial()) {
    on<RequestVerificationCodeRequested>(_onRequestCode);
    on<VerifyVerificationCodeRequested>(_onVerifyCode);
  }

  final GeneralUserRequestVerificationCode _requestCode;
  final GeneralUserVerifyVerificationCode _verifyCode;

  Future<void> _onRequestCode(
    RequestVerificationCodeRequested event,
    Emitter<GeneralUserForgotPasswordState> emit,
  ) async {
    AppLogger.i('RequestVerificationCodeRequested');
    emit(const GeneralUserForgotPasswordRequestingCode());

    final result = await _requestCode.call(
      emailAddress: event.emailAddress,
    );

    result.fold(
      (failure) {
        emit(GeneralUserForgotPasswordError(message: failure.message));
      },
      (response) {
        emit(
          GeneralUserForgotPasswordCodeRequested(
            message: response.result,
          ),
        );
      },
    );
  }

  Future<void> _onVerifyCode(
    VerifyVerificationCodeRequested event,
    Emitter<GeneralUserForgotPasswordState> emit,
  ) async {
    AppLogger.i('VerifyVerificationCodeRequested');
    emit(const GeneralUserForgotPasswordVerifyingCode());

    final result = await _verifyCode.call(
      emailAddress: event.emailAddress,
      verificationCode: event.verificationCode,
    );

    result.fold(
      (failure) {
        emit(GeneralUserForgotPasswordError(message: failure.message));
      },
      (response) {
        emit(
          GeneralUserForgotPasswordVerified(
            resetToken: response.result.resetToken,
          ),
        );
      },
    );
  }
}

