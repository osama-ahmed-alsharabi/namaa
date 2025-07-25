// features/auth/login/cubit/login_state.dart
part of 'login_cubit.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String userId;

  LoginSuccess({required this.userId});
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure(this.error);
}