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

/// Continue from multi-buoy selection — loads [GetBuoyDataReportForExport].
final class GeneralUserExportSelectionBuoysExtra extends GeneralUserExportRouteExtra {
  const GeneralUserExportSelectionBuoysExtra({required this.buoyIds});

  final List<String> buoyIds;

  @override
  List<Object?> get props => [buoyIds];
}
