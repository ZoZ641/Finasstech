import 'package:finasstech/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:finasstech/features/auth/domain/usecases/user_sign_up.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../../../../core/common/entities/user.dart';
import '../../../../core/usecase/noparams.dart';
import '../../domain/usecases/user_sign_in.dart';
import '../../domain/usecases/user_sign_out.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserSingIn _userSingIn;
  final UserSignOut _userSignOut;
  final AppUserCubit _appUserCubit;
  AuthBloc({
    required UserSignUp userSignUp,
    required UserSingIn userSingIn,
    required AppUserCubit appUserCubit,
    required UserSignOut userSignOut,
  }) : _userSignUp = userSignUp,
       _userSingIn = userSingIn,
       _appUserCubit = appUserCubit,
       _userSignOut = userSignOut,
       super(AuthInitial()) {
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthSignIn>(_onAuthSignIn);
    on<AuthSignOut>(_onAuthSignOut);
  }

  void _onAuthSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _userSignUp(
      UserSignUpParams(email: event.email, password: event.password),
    );

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _onAuthSignIn(AuthSignIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _userSingIn(
      UserSingInParams(email: event.email, password: event.password),
    );

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _emitAuthSuccess(User user, Emitter<AuthState> emit) {
    _appUserCubit.emit(AppUserAuthenticated(user));
    emit(AuthSuccess(user));
  }

  void _onAuthSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    final res = await _userSignOut(NoParams());
    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _appUserCubit.emit(AppUserUnauthenticated()),
    );
  }
}
