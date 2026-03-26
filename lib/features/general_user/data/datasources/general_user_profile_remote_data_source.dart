import 'dart:convert';

import 'package:drifter_buoy/core/constants/api_endpoints.dart';
import 'package:drifter_buoy/core/network/api_service.dart';
import 'package:drifter_buoy/core/utils/typedefs.dart';
import 'package:drifter_buoy/features/general_user/data/models/admin_user_update_user_profile_response.dart';
import 'package:dio/dio.dart';

class GeneralUserProfileRemoteDataSource {
  const GeneralUserProfileRemoteDataSource({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  ResultFuture<AdminUserUpdateUserProfileResponse> updateUserProfile({
    required String userId,
    required String firstName,
    required String middleName,
    required String lastName,
    required String mobileNumber,
    required String emailAddress,
  }) {
    final formData = FormData.fromMap({
      'FirstName': firstName,
      'MiddleName': middleName,
      'LastName': lastName,
      'MobileNumber': mobileNumber,
      'EmailAddress': emailAddress,
      '_id': userId,
    });

    return _apiService.post<AdminUserUpdateUserProfileResponse>(
      ApiEndpoints.updateUserProfileUrl,
      data: formData,
      parser: (dynamic data) {
        if (data is String) {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            return AdminUserUpdateUserProfileResponse.fromJson(decoded);
          }
        }

        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid update profile response format');
        }

        return AdminUserUpdateUserProfileResponse.fromJson(data);
      },
    );
  }
}

