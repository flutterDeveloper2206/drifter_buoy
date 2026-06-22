import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/datasources/general_user_buoy_setup_remote_data_source.dart';
import 'package:drifter_buoy/features/general_user/data/models/create_new_drifter_buoy_response.dart';
import 'package:drifter_buoy/features/general_user/domain/repositories/general_user_buoy_setup_repository.dart';

class GeneralUserBuoySetupRepositoryImpl
    implements GeneralUserBuoySetupRepository {
  GeneralUserBuoySetupRepositoryImpl({
    required GeneralUserBuoySetupRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final GeneralUserBuoySetupRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<CreateNewDrifterBuoyResponse> createNewDrifterBuoy({
    required String stationId,
    required String stationName,
    required String transmissionInterval,
    required String transmissionStartTime,
  }) {
    return _remoteDataSource.createNewDrifterBuoy(
      stationId: stationId,
      stationName: stationName,
      transmissionInterval: transmissionInterval,
      transmissionStartTime: transmissionStartTime,
    );
  }
}
