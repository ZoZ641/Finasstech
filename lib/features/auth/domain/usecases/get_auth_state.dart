import '../../../../core/common/entities/user.dart';
import '../repository/auth_repository.dart';

class GetAuthStateChanges {
  final AuthRepository authRepository;
  GetAuthStateChanges(this.authRepository);

  Stream<User?> call() => authRepository.authStateChanges();
}
