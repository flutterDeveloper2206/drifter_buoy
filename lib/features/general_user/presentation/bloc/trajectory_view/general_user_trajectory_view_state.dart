import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_trajectory_live_map_view.dart';
import 'package:equatable/equatable.dart';

enum GeneralUserTrajectoryViewStatus { initial, loading, loaded, error }

class GeneralUserTrajectoryViewState extends Equatable {
  final GeneralUserTrajectoryViewStatus status;
  final String buoyId;
  final List<TrajectoryBuoyPoint> trajectoryPoints;
  final double zoom;
  final DateTime fromDate;
  final DateTime toDate;
  final int intervalMinutes;
  final String message;

  const GeneralUserTrajectoryViewState({
    required this.status,
    required this.buoyId,
    required this.trajectoryPoints,
    required this.zoom,
    required this.fromDate,
    required this.toDate,
    required this.intervalMinutes,
    required this.message,
  });

  GeneralUserTrajectoryViewState.initial()
    : status = GeneralUserTrajectoryViewStatus.initial,
      buoyId = 'DB-01',
      trajectoryPoints = const [],
      zoom = 10.3,
      fromDate = _today,
      toDate = _today,
      intervalMinutes = 10,
      message = '';

  bool get canZoomIn => zoom < 21;

  bool get canZoomOut => zoom > 3;

  GeneralUserTrajectoryViewState copyWith({
    GeneralUserTrajectoryViewStatus? status,
    String? buoyId,
    List<TrajectoryBuoyPoint>? trajectoryPoints,
    double? zoom,
    DateTime? fromDate,
    DateTime? toDate,
    int? intervalMinutes,
    String? message,
  }) {
    return GeneralUserTrajectoryViewState(
      status: status ?? this.status,
      buoyId: buoyId ?? this.buoyId,
      trajectoryPoints: trajectoryPoints ?? this.trajectoryPoints,
      zoom: zoom ?? this.zoom,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [
    status,
    buoyId,
    trajectoryPoints,
    zoom,
    fromDate,
    toDate,
    intervalMinutes,
    message,
  ];
}

final DateTime _today = DateTime(
  DateTime.now().year,
  DateTime.now().month,
  DateTime.now().day,
);
