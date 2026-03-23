import 'package:drifter_buoy/core/error/error_handler.dart';
import 'package:drifter_buoy/core/utils/app_logger.dart';
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
    AppLogger.i('FetchItems event triggered');
    emit(const ItemsLoading());

    final result = await getItems();
    result.fold(
      (failure) {
        AppLogger.w('FetchItems failed', error: failure.message);
        emit(ItemsError(message: ErrorHandler.getErrorMessage(failure)));
      },
      (items) {
        AppLogger.i('FetchItems success: ${items.length} items');
        emit(ItemsLoaded(items: items));
      },
    );
  }

  Future<void> _onAddItem(AddItemEvent event, Emitter<ItemsState> emit) async {
    AppLogger.i('AddItemEvent triggered');
    final currentItems = _getCurrentItems();
    emit(const ItemsLoading());

    final result = await addItem(
      AddItemParams(title: event.title, body: event.body),
    );

    result.fold(
      (failure) {
        AppLogger.w('AddItemEvent failed', error: failure.message);
        emit(ItemsError(message: ErrorHandler.getErrorMessage(failure)));
      },
      (createdItem) {
        final updatedItems = List<ItemModel>.from(currentItems)
          ..insert(0, createdItem);

        AppLogger.i('AddItemEvent success: item added');
        emit(ItemsLoaded(items: updatedItems));
      },
    );
  }

  Future<void> _onDeleteItem(
    DeleteItemEvent event,
    Emitter<ItemsState> emit,
  ) async {
    AppLogger.i('DeleteItemEvent triggered: id=${event.id}');
    final currentItems = _getCurrentItems();
    emit(const ItemsLoading());

    final result = await deleteItem(DeleteItemParams(event.id));

    result.fold(
      (failure) {
        AppLogger.w('DeleteItemEvent failed', error: failure.message);
        emit(ItemsError(message: ErrorHandler.getErrorMessage(failure)));
      },
      (_) {
        final updatedItems = currentItems
            .where((item) => item.id != event.id)
            .toList(growable: false);

        AppLogger.i('DeleteItemEvent success: id=${event.id}');
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
