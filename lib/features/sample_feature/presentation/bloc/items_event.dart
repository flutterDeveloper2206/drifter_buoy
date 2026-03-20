import 'package:equatable/equatable.dart';

abstract class ItemsEvent extends Equatable {
  const ItemsEvent();

  @override
  List<Object?> get props => [];
}

class FetchItems extends ItemsEvent {
  const FetchItems();
}

class AddItemEvent extends ItemsEvent {
  final String title;
  final String body;

  const AddItemEvent({required this.title, required this.body});

  @override
  List<Object> get props => [title, body];
}

class DeleteItemEvent extends ItemsEvent {
  final int id;

  const DeleteItemEvent(this.id);

  @override
  List<Object> get props => [id];
}
