import 'package:drifter_buoy/features/general_user/presentation/bloc/buoys/general_user_buoys_state.dart';
import 'package:equatable/equatable.dart';

abstract class GeneralUserBuoysEvent extends Equatable {
  const GeneralUserBuoysEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserBuoys extends GeneralUserBuoysEvent {
  const LoadGeneralUserBuoys();
}

class UpdateGeneralUserBuoysQuery extends GeneralUserBuoysEvent {
  final String query;

  const UpdateGeneralUserBuoysQuery(this.query);

  @override
  List<Object> get props => [query];
}

class ClearGeneralUserBuoysQuery extends GeneralUserBuoysEvent {
  const ClearGeneralUserBuoysQuery();
}

class ChangeGeneralUserBuoysFilter extends GeneralUserBuoysEvent {
  final GeneralUserBuoyFilter filter;

  const ChangeGeneralUserBuoysFilter(this.filter);

  @override
  List<Object> get props => [filter];
}
