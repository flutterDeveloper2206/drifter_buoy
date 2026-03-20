import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/sample_feature/data/datasources/item_remote_data_source.dart';
import 'package:drifter_buoy/features/sample_feature/data/models/item_model.dart';
import 'package:drifter_buoy/features/sample_feature/domain/repositories/item_repository.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemRemoteDataSource remoteDataSource;

  ItemRepositoryImpl({required this.remoteDataSource});

  @override
  ResultFuture<List<ItemModel>> getItems() {
    return remoteDataSource.getItems();
  }

  @override
  ResultFuture<ItemModel> addItem({
    required String title,
    required String body,
  }) {
    return remoteDataSource.addItem(title: title, body: body);
  }

  @override
  ResultFuture<void> deleteItem(int id) {
    return remoteDataSource.deleteItem(id);
  }
}
