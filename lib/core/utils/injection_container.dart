import 'package:drifter_buoy/core/constants/app_constants.dart';
import 'package:drifter_buoy/core/network/api_service.dart';
import 'package:drifter_buoy/features/sample_feature/data/datasources/item_remote_data_source.dart';
import 'package:drifter_buoy/features/sample_feature/data/repositories/item_repository_impl.dart';
import 'package:drifter_buoy/features/sample_feature/domain/repositories/item_repository.dart';
import 'package:drifter_buoy/features/sample_feature/domain/usecases/add_item.dart';
import 'package:drifter_buoy/features/sample_feature/domain/usecases/delete_item.dart';
import 'package:drifter_buoy/features/sample_feature/domain/usecases/get_items.dart';
import 'package:drifter_buoy/features/sample_feature/presentation/bloc/items_bloc.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  if (sl.isRegistered<ItemsBloc>()) {
    return;
  }

  sl.registerLazySingleton<ApiService>(
    () => ApiService(baseUrl: AppConstants.baseUrl),
  );

  sl.registerLazySingleton<ItemRemoteDataSource>(
    () => ItemRemoteDataSourceImpl(apiService: sl()),
  );

  sl.registerLazySingleton<ItemRepository>(
    () => ItemRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<GetItems>(() => GetItems(sl()));
  sl.registerLazySingleton<AddItem>(() => AddItem(sl()));
  sl.registerLazySingleton<DeleteItem>(() => DeleteItem(sl()));

  sl.registerFactory<ItemsBloc>(
    () => ItemsBloc(getItems: sl(), addItem: sl(), deleteItem: sl()),
  );
}
