part of 'signup_cubit.dart';

@freezed
class SignupState with _$SignupState {
  const factory SignupState.initial() = _Initial;
  const factory SignupState.loading() = _Loading;
  const factory SignupState.codeSent({
    required String verificationId,
    required String phoneNumber,
    required String name,
    required String age,
    required String gender,
    required String password,
  }) = _CodeSent;
  const factory SignupState.success() = _Success;
  const factory SignupState.error(String message) = _Error;
}