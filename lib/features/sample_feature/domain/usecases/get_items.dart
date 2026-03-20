import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/sample_feature/data/models/item_model.dart';
import 'package:drifter_buoy/features/sample_feature/domain/repositories/item_repository.dart';

class GetItems {
  final ItemRepository repository;

  GetItems(this.repository);

  ResultFuture<List<ItemModel>> call() {
    return repository.getItems();
  }
}
