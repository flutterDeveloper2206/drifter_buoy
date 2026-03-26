class ApiEndpoints {
  const ApiEndpoints._();

  static const String loginUrl =
      'http://4.213.34.231:5025/api/UserAuthenticate/Login';

  static const String requestVerificationCodeUrl =
      'http://4.213.34.231:5025/api/UserAuthenticate/RequestVerificationCode';

  static const String verifyVerificationCodeUrl =
      'http://4.213.34.231:5025/api/UserAuthenticate/VerifyVerificationCode';
}
