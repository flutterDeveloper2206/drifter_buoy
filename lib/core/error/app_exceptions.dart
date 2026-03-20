abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode == null) {
      return message;
    }
    return '$message (status code: $statusCode)';
  }
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class ApiException extends AppException {
  const ApiException(super.message, {super.statusCode});
}

class ParsingException extends AppException {
  const ParsingException(super.message);
}

class UnknownException extends AppException {
  const UnknownException(super.message);
}
