import 'package:equatable/equatable.dart';

abstract class GeneralUserMapSearchEvent extends Equatable {
  const GeneralUserMapSearchEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserMapSearch extends GeneralUserMapSearchEvent {
  const LoadGeneralUserMapSearch();
}

class UpdateGeneralUserMapSearchQuery extends GeneralUserMapSearchEvent {
  final String query;

  const UpdateGeneralUserMapSearchQuery(this.query);

  @override
  List<Object> get props => [query];
}

class ClearGeneralUserMapSearchQuery extends GeneralUserMapSearchEvent {
  const ClearGeneralUserMapSearchQuery();
}

class ZoomInGeneralUserMapSearch extends GeneralUserMapSearchEvent {
  const ZoomInGeneralUserMapSearch();
}

class ZoomOutGeneralUserMapSearch extends GeneralUserMapSearchEvent {
  const ZoomOutGeneralUserMapSearch();
}
