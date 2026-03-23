import 'package:equatable/equatable.dart';

abstract class GeneralUserExportSelectionEvent extends Equatable {
  const GeneralUserExportSelectionEvent();

  @override
  List<Object?> get props => [];
}

class LoadGeneralUserExportSelection extends GeneralUserExportSelectionEvent {
  const LoadGeneralUserExportSelection();
}

class UpdateGeneralUserExportSelectionQuery
    extends GeneralUserExportSelectionEvent {
  final String query;

  const UpdateGeneralUserExportSelectionQuery(this.query);

  @override
  List<Object> get props => [query];
}

class ToggleGeneralUserExportSelectionItem
    extends GeneralUserExportSelectionEvent {
  final String id;

  const ToggleGeneralUserExportSelectionItem(this.id);

  @override
  List<Object> get props => [id];
}

class ToggleGeneralUserExportSelectionAll
    extends GeneralUserExportSelectionEvent {
  const ToggleGeneralUserExportSelectionAll();
}
