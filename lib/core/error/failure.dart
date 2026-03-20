import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Network error. Please check your connection.',
  ]) : super();
}

class ApiFailure extends Failure {
  const ApiFailure([
    super.message = 'Request failed. Please try again.',
    int? statusCode,
  ]) : super(statusCode: statusCode);
}

class ParsingFailure extends Failure {
  const ParsingFailure([super.message = 'Failed to parse server response.'])
    : super();
}

class UnknownFailure extends Failure {
  const UnknownFailure([
    super.message = 'Something went wrong. Please try again.',
  ]) : super();
}
