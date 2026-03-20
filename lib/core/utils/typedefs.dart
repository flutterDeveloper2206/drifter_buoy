import 'package:dartz_plus/dartz_plus.dart';
import 'package:drifter_buoy/core/error/failure.dart';

typedef ResultFuture<T> = Future<Either<Failure, T>>;
