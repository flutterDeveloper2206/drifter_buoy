import 'dart:convert';

import 'package:dartz_plus/dartz_plus.dart';
import 'package:drifter_buoy/core/constants/api_endpoints.dart';
import 'package:drifter_buoy/core/constants/app_constants.dart';
import 'package:drifter_buoy/core/error/failure.dart';
import 'package:drifter_buoy/core/network/api_service.dart';
import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/drifter_buoy_command_model.dart';

class GeneralUserSelfTestRemoteDataSource {
  const GeneralUserSelfTestRemoteDataSource({required ApiService apiService})
    : _apiService = apiService;

  final ApiService _apiService;

  ResultFuture<GetAllDrifterBuoyCommandsResponse>
  getAllDrifterBuoyCommands() async {
    const maxAttempts = AppConstants.drifterCommandsCatalogMaxAttempts;
    Failure? lastFailure;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      final result = await _apiService.post<GetAllDrifterBuoyCommandsResponse>(
        ApiEndpoints.getAllDrifterBuoyCommandsUrl,
        data: const <String, dynamic>{},
        receiveTimeout: AppConstants.drifterCommandsCatalogReceiveTimeout,
        parser: _parseGetAllDrifterBuoyCommandsResponse,
      );

      final succeeded = result.fold((failure) {
        lastFailure = failure;
        return false;
      }, (_) => true);

      if (succeeded) {
        if (attempt > 1) {
          AppLogger.i(
            'GetAllDrifterBuoyCommands succeeded on attempt $attempt/$maxAttempts',
          );
        }
        return result;
      }

      if (attempt >= maxAttempts || !_isRetryableFailure(lastFailure!)) {
        return Left(lastFailure!);
      }

      AppLogger.w(
        'GetAllDrifterBuoyCommands attempt $attempt/$maxAttempts failed '
        '(${lastFailure!.message}). Retrying…',
      );
      await Future<void>.delayed(Duration(seconds: 2 * attempt));
    }

    return Left(
      lastFailure ?? const UnknownFailure('Failed to load self-test commands.'),
    );
  }

  static GetAllDrifterBuoyCommandsResponse
  _parseGetAllDrifterBuoyCommandsResponse(dynamic data) {
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        return GetAllDrifterBuoyCommandsResponse.fromJson(decoded);
      }
    }
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid GetAllDrifterBuoyCommands response');
    }
    return GetAllDrifterBuoyCommandsResponse.fromJson(data);
  }

  static bool _isRetryableFailure(Failure failure) {
    if (failure is NetworkFailure) {
      return true;
    }
    if (failure is UnknownFailure) {
      final msg = failure.message.toLowerCase();
      return msg.contains('connection closed') ||
          msg.contains('connection reset') ||
          msg.contains('timeout') ||
          msg.contains('socket');
    }
    return false;
  }
}
