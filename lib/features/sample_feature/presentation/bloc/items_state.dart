import 'package:drifter_buoy/features/sample_feature/data/models/item_model.dart';
import 'package:equatable/equatable.dart';

abstract class ItemsState extends Equatable {
  const ItemsState();

  @override
  List<Object?> get props => [];
}

class ItemsInitial extends ItemsState {
  const ItemsInitial();
}

class ItemsLoading extends ItemsState {
  const ItemsLoading();
}

class ItemsLoaded extends ItemsState {
  final List<ItemModel> items;

  const ItemsLoaded({required this.items});

  ItemsLoaded copyWith({List<ItemModel>? items}) {
    return ItemsLoaded(items: items ?? this.items);
  }

  @override
  List<Object> get props => [items];
}

class ItemsError extends ItemsState {
  final String message;

  const ItemsError({required this.message});

  @override
  List<Object> get props => [message];
}
