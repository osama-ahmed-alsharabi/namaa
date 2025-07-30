part of 'login_cubit.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginCodeSent extends LoginState {}

class LoginSuccess extends LoginState {
  final String userId;
  LoginSuccess({required this.userId});
}

class LoginFailure extends LoginState {
  final String message;
  LoginFailure(this.message);
}
