import 'package:equatable/equatable.dart';

enum GeneralUserSelfTestDebugStatus { initial, loading, loaded, running, error }

class GeneralUserSelfTestDebugState extends Equatable {
  final GeneralUserSelfTestDebugStatus status;
  final List<String> actions;
  final String? runningAction;
  final String message;
  final bool isSuccessMessage;

  const GeneralUserSelfTestDebugState({
    required this.status,
    required this.actions,
    required this.runningAction,
    required this.message,
    required this.isSuccessMessage,
  });

  const GeneralUserSelfTestDebugState.initial()
    : status = GeneralUserSelfTestDebugStatus.initial,
      actions = const [],
      runningAction = null,
      message = '',
      isSuccessMessage = false;

  GeneralUserSelfTestDebugState copyWith({
    GeneralUserSelfTestDebugStatus? status,
    List<String>? actions,
    String? runningAction,
    bool clearRunningAction = false,
    String? message,
    bool? isSuccessMessage,
  }) {
    return GeneralUserSelfTestDebugState(
      status: status ?? this.status,
      actions: actions ?? this.actions,
      runningAction: clearRunningAction
          ? null
          : (runningAction ?? this.runningAction),
      message: message ?? this.message,
      isSuccessMessage: isSuccessMessage ?? this.isSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    actions,
    runningAction,
    message,
    isSuccessMessage,
  ];
}
