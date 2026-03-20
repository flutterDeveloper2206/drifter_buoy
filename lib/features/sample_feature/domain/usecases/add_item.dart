import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/sample_feature/data/models/item_model.dart';
import 'package:drifter_buoy/features/sample_feature/domain/repositories/item_repository.dart';
import 'package:equatable/equatable.dart';

class AddItem {
  final ItemRepository repository;

  AddItem(this.repository);

  ResultFuture<ItemModel> call(AddItemParams params) {
    return repository.addItem(title: params.title, body: params.body);
  }
}

class AddItemParams extends Equatable {
  final String title;
  final String body;

  const AddItemParams({required this.title, required this.body});

  @override
  List<Object> get props => [title, body];
}
