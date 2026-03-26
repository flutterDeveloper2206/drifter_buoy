import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/features/general_user/domain/usecases/general_user_update_user_profile.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile_update/general_user_update_profile_event.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/profile_update/general_user_update_profile_state.dart';

class GeneralUserUpdateProfileBloc extends Bloc<
    GeneralUserUpdateProfileEvent, GeneralUserUpdateProfileState> {
  GeneralUserUpdateProfileBloc({
    required GeneralUserUpdateUserProfile updateUserProfile,
  })  : _updateUserProfile = updateUserProfile,
        super(const GeneralUserUpdateProfileInitial()) {
    on<UpdateGeneralUserProfileRequested>(_onUpdateRequested);
  }

  final GeneralUserUpdateUserProfile _updateUserProfile;

  Future<void> _onUpdateRequested(
    UpdateGeneralUserProfileRequested event,
    Emitter<GeneralUserUpdateProfileState> emit,
  ) async {
    AppLogger.i('UpdateGeneralUserProfileRequested');
    emit(const GeneralUserUpdateProfileLoading());

    final result = await _updateUserProfile.call(
      userId: event.userId,
      firstName: event.firstName,
      middleName: event.middleName,
      lastName: event.lastName,
      mobileNumber: event.mobileNumber,
      emailAddress: event.emailAddress,
    );

    result.fold(
      (failure) {
        emit(
          GeneralUserUpdateProfileError(message: failure.message),
        );
      },
      (response) {
        final messageText = response.result.isNotEmpty
            ? response.result
            : (response.message.isNotEmpty ? response.message : 'Success');
        emit(
          GeneralUserUpdateProfileSuccess(message: messageText),
        );
      },
    );
  }
}

