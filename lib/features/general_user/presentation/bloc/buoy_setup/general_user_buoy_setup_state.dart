import 'package:equatable/equatable.dart';

enum GeneralUserBuoySetupStatus { initial, loading, loaded, saving, error }

class GeneralUserBuoySetupState extends Equatable {
  final GeneralUserBuoySetupStatus status;
  final String stationId;
  final String stationName;
  final String transmissionInterval;
  final String transmissionStartTime;
  final String message;
  final bool isSuccessMessage;

  const GeneralUserBuoySetupState({
    required this.status,
    required this.stationId,
    required this.stationName,
    required this.transmissionInterval,
    required this.transmissionStartTime,
    required this.message,
    required this.isSuccessMessage,
  });

  const GeneralUserBuoySetupState.initial()
    : status = GeneralUserBuoySetupStatus.initial,
      stationId = '',
      stationName = '',
      transmissionInterval = '',
      transmissionStartTime = '',
      message = '',
      isSuccessMessage = false;

  GeneralUserBuoySetupState copyWith({
    GeneralUserBuoySetupStatus? status,
    String? stationId,
    String? stationName,
    String? transmissionInterval,
    String? transmissionStartTime,
    String? message,
    bool? isSuccessMessage,
  }) {
    return GeneralUserBuoySetupState(
      status: status ?? this.status,
      stationId: stationId ?? this.stationId,
      stationName: stationName ?? this.stationName,
      transmissionInterval: transmissionInterval ?? this.transmissionInterval,
      transmissionStartTime:
          transmissionStartTime ?? this.transmissionStartTime,
      message: message ?? this.message,
      isSuccessMessage: isSuccessMessage ?? this.isSuccessMessage,
    );
  }

  @override
  List<Object> get props => [
    status,
    stationId,
    stationName,
    transmissionInterval,
    transmissionStartTime,
    message,
    isSuccessMessage,
  ];
}
