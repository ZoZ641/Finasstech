import 'package:finasstech/core/error/failures.dart';
import 'package:finasstech/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/user.dart';
import '../repository/auth_repository.dart';

class UserSingIn implements UseCase<User, UserSingInParams> {
  final AuthRepository authRepository;
  const UserSingIn(this.authRepository);
  @override
  Future<Either<Failure, User>> call(UserSingInParams params) async {
    return await authRepository.signInWithEmailPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class UserSingInParams {
  final String email;
  final String password;
  UserSingInParams({required this.email, required this.password});
}
