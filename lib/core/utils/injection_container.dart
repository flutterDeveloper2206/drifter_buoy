import 'package:drifter_buoy/core/constants/app_constants.dart';
import 'package:drifter_buoy/core/network/api_service.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoys/general_user_buoys_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/buoy_overview/general_user_buoy_overview_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/export/general_user_export_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map/general_user_map_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_buoy_details/general_user_map_buoy_details_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_filters/general_user_map_filters_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/map_search/general_user_map_search_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/metrics/general_user_metrics_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_filters/general_user_trajectory_filters_bloc.dart';
import 'package:drifter_buoy/features/general_user/presentation/bloc/trajectory_view/general_user_trajectory_view_bloc.dart';
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
  if (!sl.isRegistered<ApiService>()) {
    sl.registerLazySingleton<ApiService>(
      () => ApiService(baseUrl: AppConstants.baseUrl),
    );
  }

  if (!sl.isRegistered<ItemRemoteDataSource>()) {
    sl.registerLazySingleton<ItemRemoteDataSource>(
      () => ItemRemoteDataSourceImpl(apiService: sl()),
    );
  }

  if (!sl.isRegistered<ItemRepository>()) {
    sl.registerLazySingleton<ItemRepository>(
      () => ItemRepositoryImpl(remoteDataSource: sl()),
    );
  }

  if (!sl.isRegistered<GetItems>()) {
    sl.registerLazySingleton<GetItems>(() => GetItems(sl()));
  }
  if (!sl.isRegistered<AddItem>()) {
    sl.registerLazySingleton<AddItem>(() => AddItem(sl()));
  }
  if (!sl.isRegistered<DeleteItem>()) {
    sl.registerLazySingleton<DeleteItem>(() => DeleteItem(sl()));
  }

  if (!sl.isRegistered<ItemsBloc>()) {
    sl.registerFactory<ItemsBloc>(
      () => ItemsBloc(getItems: sl(), addItem: sl(), deleteItem: sl()),
    );
  }

  if (!sl.isRegistered<GeneralUserMapBloc>()) {
    sl.registerFactory<GeneralUserMapBloc>(() => GeneralUserMapBloc());
  }

  if (!sl.isRegistered<GeneralUserMapFiltersBloc>()) {
    sl.registerFactory<GeneralUserMapFiltersBloc>(
      () => GeneralUserMapFiltersBloc(),
    );
  }

  if (!sl.isRegistered<GeneralUserMapBuoyDetailsBloc>()) {
    sl.registerFactory<GeneralUserMapBuoyDetailsBloc>(
      () => GeneralUserMapBuoyDetailsBloc(),
    );
  }

  if (!sl.isRegistered<GeneralUserMapSearchBloc>()) {
    sl.registerFactory<GeneralUserMapSearchBloc>(
      () => GeneralUserMapSearchBloc(),
    );
  }

  if (!sl.isRegistered<GeneralUserBuoyOverviewBloc>()) {
    sl.registerFactory<GeneralUserBuoyOverviewBloc>(
      () => GeneralUserBuoyOverviewBloc(),
    );
  }

  if (!sl.isRegistered<GeneralUserTrajectoryViewBloc>()) {
    sl.registerFactory<GeneralUserTrajectoryViewBloc>(
      () => GeneralUserTrajectoryViewBloc(),
    );
  }

  if (!sl.isRegistered<GeneralUserTrajectoryFiltersBloc>()) {
    sl.registerFactory<GeneralUserTrajectoryFiltersBloc>(
      () => GeneralUserTrajectoryFiltersBloc(),
    );
  }

  if (!sl.isRegistered<GeneralUserExportBloc>()) {
    sl.registerFactory<GeneralUserExportBloc>(() => GeneralUserExportBloc());
  }

  if (!sl.isRegistered<GeneralUserBuoysBloc>()) {
    sl.registerFactory<GeneralUserBuoysBloc>(() => GeneralUserBuoysBloc());
  }

  if (!sl.isRegistered<GeneralUserMetricsBloc>()) {
    sl.registerFactory<GeneralUserMetricsBloc>(() => GeneralUserMetricsBloc());
  }
}
