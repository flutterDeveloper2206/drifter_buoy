import 'package:equatable/equatable.dart';

class UserAuthenticateLoginResult extends Equatable {
  final String userId;
  final String roleName;
  final String userCode;
  final String firstName;
  final String middleName;
  final String lastName;
  final String fullName;
  final String userName;
  final String emailAddress;
  final String mobileNumber;
  final String clientCode;
  final String token;
  final String refreshToken;
  final String dbProvider;
  final dynamic profileDetails;
  final List<dynamic> profileDetailsList;
  final bool isActive;

  const UserAuthenticateLoginResult({
    required this.userId,
    required this.roleName,
    required this.userCode,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.fullName,
    required this.userName,
    required this.emailAddress,
    required this.mobileNumber,
    required this.clientCode,
    required this.token,
    required this.refreshToken,
    required this.dbProvider,
    required this.profileDetails,
    required this.profileDetailsList,
    required this.isActive,
  });

  factory UserAuthenticateLoginResult.fromJson(Map<String, dynamic> json) {
    return UserAuthenticateLoginResult(
      userId: (json['userId'] ?? '').toString(),
      roleName: (json['roleName'] ?? '').toString(),
      userCode: (json['userCode'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      middleName: (json['middleName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      userName: (json['userName'] ?? '').toString(),
      emailAddress: (json['emailAddress'] ?? '').toString(),
      mobileNumber: (json['mobileNumber'] ?? '').toString(),
      clientCode: (json['clientCode'] ?? '').toString(),
      token: (json['token'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
      dbProvider: (json['dbProvider'] ?? '').toString(),
      profileDetails: json['profileDetails'],
      profileDetailsList:
          (json['profileDetailsList'] as List<dynamic>?) ?? const [],
      isActive: (json['isActive'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'roleName': roleName,
      'userCode': userCode,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'fullName': fullName,
      'userName': userName,
      'emailAddress': emailAddress,
      'mobileNumber': mobileNumber,
      'clientCode': clientCode,
      'token': token,
      'refreshToken': refreshToken,
      'dbProvider': dbProvider,
      'profileDetails': profileDetails,
      'profileDetailsList': profileDetailsList,
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [
        userId,
        roleName,
        userCode,
        firstName,
        middleName,
        lastName,
        fullName,
        userName,
        emailAddress,
        mobileNumber,
        clientCode,
        token,
        refreshToken,
        dbProvider,
        profileDetails,
        profileDetailsList,
        isActive,
      ];
}

class UserAuthenticateLoginResponse extends Equatable {
  final int statusCode;
  final String message;
  final UserAuthenticateLoginResult result;
  final bool isSuccess;

  const UserAuthenticateLoginResponse({
    required this.statusCode,
    required this.message,
    required this.result,
    required this.isSuccess,
  });

  factory UserAuthenticateLoginResponse.fromJson(Map<String, dynamic> json) {
    return UserAuthenticateLoginResponse(
      statusCode: (json['statusCode'] ?? 0) as int,
      message: (json['message'] ?? '').toString(),
      isSuccess: (json['isSuccess'] ?? false) as bool,
      result: UserAuthenticateLoginResult.fromJson(
        (json['result'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'statusCode': statusCode,
      'message': message,
      'result': result.toJson(),
      'isSuccess': isSuccess,
    };
  }

  @override
  List<Object?> get props => [statusCode, message, result, isSuccess];
}

