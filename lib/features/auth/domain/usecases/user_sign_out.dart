import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';

class UserSignOut implements UseCase<void, NoParams> {
  final AuthRepository authRepository;
  const UserSignOut(this.authRepository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return authRepository.signOut();
  }
}

class NoParams {}
