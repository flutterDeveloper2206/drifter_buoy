import 'package:equatable/equatable.dart';

/// Pass via [GoRouterState.extra] when opening [GeneralUserMetricsPage].
final class GeneralUserMetricsRouteExtra extends Equatable {
  const GeneralUserMetricsRouteExtra({
    required this.buoyId,
    this.focusBatterySection = true,
  });

  final String buoyId;

  /// When true (e.g. from overview metrics card), scroll to the battery chart.
  final bool focusBatterySection;

  @override
  List<Object?> get props => [buoyId, focusBatterySection];
}
