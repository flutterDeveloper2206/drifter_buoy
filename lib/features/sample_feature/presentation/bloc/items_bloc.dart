import 'package:drifter_buoy/core/error/error_handler.dart';
import 'package:drifter_buoy/features/sample_feature/data/models/item_model.dart';
import 'package:drifter_buoy/features/sample_feature/domain/usecases/add_item.dart';
import 'package:drifter_buoy/features/sample_feature/domain/usecases/delete_item.dart';
import 'package:drifter_buoy/features/sample_feature/domain/usecases/get_items.dart';
import 'package:drifter_buoy/features/sample_feature/presentation/bloc/items_event.dart';
import 'package:drifter_buoy/features/sample_feature/presentation/bloc/items_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemsBloc extends Bloc<ItemsEvent, ItemsState> {
  final GetItems getItems;
  final AddItem addItem;
  final DeleteItem deleteItem;

  ItemsBloc({
    required this.getItems,
    required this.addItem,
    required this.deleteItem,
  }) : super(const ItemsInitial()) {
    on<FetchItems>(_onFetchItems);
    on<AddItemEvent>(_onAddItem);
    on<DeleteItemEvent>(_onDeleteItem);
  }

  Future<void> _onFetchItems(FetchItems event, Emitter<ItemsState> emit) async {
    emit(const ItemsLoading());

    final result = await getItems();
    result.fold(
      (failure) =>
          emit(ItemsError(message: ErrorHandler.getErrorMessage(failure))),
      (items) => emit(ItemsLoaded(items: items)),
    );
  }

  Future<void> _onAddItem(AddItemEvent event, Emitter<ItemsState> emit) async {
    final currentItems = _getCurrentItems();
    emit(const ItemsLoading());

    final result = await addItem(
      AddItemParams(title: event.title, body: event.body),
    );

    result.fold(
      (failure) =>
          emit(ItemsError(message: ErrorHandler.getErrorMessage(failure))),
      (createdItem) {
        final updatedItems = List<ItemModel>.from(currentItems)
          ..insert(0, createdItem);

        emit(ItemsLoaded(items: updatedItems));
      },
    );
  }

  Future<void> _onDeleteItem(
    DeleteItemEvent event,
    Emitter<ItemsState> emit,
  ) async {
    final currentItems = _getCurrentItems();
    emit(const ItemsLoading());

    final result = await deleteItem(DeleteItemParams(event.id));

    result.fold(
      (failure) =>
          emit(ItemsError(message: ErrorHandler.getErrorMessage(failure))),
      (_) {
        final updatedItems = currentItems
            .where((item) => item.id != event.id)
            .toList(growable: false);

        emit(ItemsLoaded(items: updatedItems));
      },
    );
  }

  List<ItemModel> _getCurrentItems() {
    final currentState = state;
    if (currentState is ItemsLoaded) {
      return currentState.items;
    }
    return const [];
  }
}
