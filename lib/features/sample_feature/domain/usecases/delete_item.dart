import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/sample_feature/domain/repositories/item_repository.dart';
import 'package:equatable/equatable.dart';

class DeleteItem {
  final ItemRepository repository;

  DeleteItem(this.repository);

  ResultFuture<void> call(DeleteItemParams params) {
    return repository.deleteItem(params.id);
  }
}

class DeleteItemParams extends Equatable {
  final int id;

  const DeleteItemParams(this.id);

  @override
  List<Object> get props => [id];
}
