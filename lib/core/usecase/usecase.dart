import 'package:finasstech/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

/* An Interface for usecases to implement */
abstract interface class UseCase<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}
