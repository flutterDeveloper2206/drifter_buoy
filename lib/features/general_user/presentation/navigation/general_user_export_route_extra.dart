import 'package:equatable/equatable.dart';

/// Pass via [GoRouterState.extra] when opening [GeneralUserExportPage].
sealed class GeneralUserExportRouteExtra extends Equatable {
  const GeneralUserExportRouteExtra();
}

/// Export distance report for a single buoy (loads API + map + CSV/PDF).
final class GeneralUserExportBuoyDistanceExtra extends GeneralUserExportRouteExtra {
  const GeneralUserExportBuoyDistanceExtra({required this.buoyId});

  final String buoyId;

  @override
  List<Object?> get props => [buoyId];
}

/// Continue from multi-buoy selection (legacy placeholder export).
final class GeneralUserExportSelectionCountExtra extends GeneralUserExportRouteExtra {
  const GeneralUserExportSelectionCountExtra(this.selectedBuoyCount);

  final int selectedBuoyCount;

  @override
  List<Object?> get props => [selectedBuoyCount];
}
