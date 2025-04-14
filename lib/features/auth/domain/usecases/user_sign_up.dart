import 'package:finasstech/core/error/failures.dart';
import 'package:finasstech/core/usecase/usecase.dart';
import '../../../../core/common/entities/user.dart';
import 'package:finasstech/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserSignUp implements UseCase<User, UserSignUpParams> {
  final AuthRepository authRepository;
  const UserSignUp(this.authRepository);
  @override
  Future<Either<Failure, User>> call(UserSignUpParams params) async {
    return await authRepository.signUpWithEmailPassword(
      email: params.email,
      password: params.password,
    );
  }
}

/* A helper class to pass parameters to the UserSignUp usecase since it has 4 parameters */
class UserSignUpParams {
  final String email;
  final String password;

  UserSignUpParams({required this.email, required this.password});
}
