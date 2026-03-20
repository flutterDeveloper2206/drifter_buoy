import 'package:drifter_buoy/core/constants/app_constants.dart';
import 'package:drifter_buoy/core/error/app_exceptions.dart';
import 'package:drifter_buoy/core/network/api_service.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/sample_feature/data/models/item_model.dart';

abstract class ItemRemoteDataSource {
  ResultFuture<List<ItemModel>> getItems();

  ResultFuture<ItemModel> addItem({
    required String title,
    required String body,
  });

  ResultFuture<void> deleteItem(int id);
}

class ItemRemoteDataSourceImpl implements ItemRemoteDataSource {
  final ApiService apiService;

  ItemRemoteDataSourceImpl({required this.apiService});

  @override
  ResultFuture<List<ItemModel>> getItems() {
    return apiService.get<List<ItemModel>>(
      AppConstants.itemsEndpoint,
      parser: (response) {
        if (response is! List) {
          throw const ParsingException('Invalid response format from server.');
        }

        return response
            .whereType<Map<String, dynamic>>()
            .map(ItemModel.fromJson)
            .toList(growable: false);
      },
    );
  }

  @override
  ResultFuture<ItemModel> addItem({
    required String title,
    required String body,
  }) {
    final payload = ItemModel(
      userId: AppConstants.defaultUserId,
      title: title,
      body: body,
    );

    return apiService.post<ItemModel>(
      AppConstants.itemsEndpoint,
      data: payload.toJson(),
      parser: (response) {
        if (response is! Map<String, dynamic>) {
          throw const ParsingException('Invalid response format from server.');
        }

        return ItemModel.fromJson(response).copyWith(
          title: title,
          body: body,
          userId: AppConstants.defaultUserId,
        );
      },
    );
  }

  @override
  ResultFuture<void> deleteItem(int id) {
    return apiService.delete('${AppConstants.itemsEndpoint}/$id');
  }
}
