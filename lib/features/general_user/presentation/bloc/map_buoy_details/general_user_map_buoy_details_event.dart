import 'package:drifter_buoy/features/general_user/presentation/widgets/dummy_buoy_map_view.dart';
import 'package:equatable/equatable.dart';

abstract class GeneralUserMapBuoyDetailsEvent extends Equatable {
  const GeneralUserMapBuoyDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserMapBuoyDetails extends GeneralUserMapBuoyDetailsEvent {
  const LoadGeneralUserMapBuoyDetails();
}

class SelectGeneralUserMapBuoy extends GeneralUserMapBuoyDetailsEvent {
  final DummyBuoy buoy;

  const SelectGeneralUserMapBuoy(this.buoy);

  @override
  List<Object> get props => [buoy];
}

class ZoomInGeneralUserMapBuoy extends GeneralUserMapBuoyDetailsEvent {
  const ZoomInGeneralUserMapBuoy();
}

class ZoomOutGeneralUserMapBuoy extends GeneralUserMapBuoyDetailsEvent {
  const ZoomOutGeneralUserMapBuoy();
}
