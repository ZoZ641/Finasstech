part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthSignUp extends AuthEvent {
  final String email;
  final String password;
  AuthSignUp({required this.email, required this.password});
}

final class AuthSignIn extends AuthEvent {
  final String email;
  final String password;
  AuthSignIn({required this.email, required this.password});
}

final class AuthSignOut extends AuthEvent {}
