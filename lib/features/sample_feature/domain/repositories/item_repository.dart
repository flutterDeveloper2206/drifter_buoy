import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/sample_feature/data/models/item_model.dart';

abstract class ItemRepository {
  ResultFuture<List<ItemModel>> getItems();

  ResultFuture<ItemModel> addItem({
    required String title,
    required String body,
  });

  ResultFuture<void> deleteItem(int id);
}
