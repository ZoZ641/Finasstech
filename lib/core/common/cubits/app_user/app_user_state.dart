part of 'app_user_cubit.dart';

@immutable
sealed class AppUserState {}

final class AppUserLoading extends AppUserState {}

final class AppUserAuthenticated extends AppUserState {
  final User user;
  AppUserAuthenticated(this.user);
}

final class AppUserUnauthenticated extends AppUserState {}
