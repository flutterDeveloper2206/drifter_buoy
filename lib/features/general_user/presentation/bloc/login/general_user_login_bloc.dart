import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_login.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/login/general_user_login_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/login/general_user_login_state.dart';

class GeneralUserLoginBloc
    extends Bloc<GeneralUserLoginEvent, GeneralUserLoginState> {
  GeneralUserLoginBloc({required GeneralUserLogin login})
      : _login = login,
        super(const GeneralUserLoginInitial()) {
    on<GeneralUserLoginRequested>(_onGeneralUserLoginRequested);
  }

  final GeneralUserLogin _login;

  Future<void> _onGeneralUserLoginRequested(
    GeneralUserLoginRequested event,
    Emitter<GeneralUserLoginState> emit,
  ) async {
    AppLogger.i('GeneralUserLoginRequested');
    emit(const GeneralUserLoginLoading());

    final result = await _login.call(
      userName: event.userName,
      password: event.password,
    );

    result.fold(
      (failure) {
        emit(GeneralUserLoginError(message: failure.message));
      },
      (response) {
        final roleName = response.result.roleName;
        final isAdmin = roleName.toLowerCase() == 'admin';
        emit(
          GeneralUserLoginAuthenticated(
            isAdmin: isAdmin,
            token: response.result.token,
            userId: response.result.userId,
            roleName: response.result.roleName,
          ),
        );
      },
    );
  }
}

