import 'package:drifter_buoy/core/error/exception_manager.dart';

class ErrorHandler {
  const ErrorHandler._();

  static String getErrorMessage(Object error) {
    return ExceptionManager.mapException(error).message;
  }
}
