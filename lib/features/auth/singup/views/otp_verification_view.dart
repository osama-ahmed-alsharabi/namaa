import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:namaa/cores/widgets/custom_button_widget.dart';
import 'package:namaa/features/auth/singup/view_model/cubit/signup_cubit.dart';
import 'package:namaa/features/start_page/start_view.dart';
import 'package:namaa/generated/l10n.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final String name;
  final String age;
  final String gender;
  final String password;

  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.name,
    required this.age,
    required this.gender,
    required this.password,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignupCubit, SignupState>(
      listener: (context, state) {
        state.whenOrNull(
          loading: () => setState(() => _isLoading = true),
          error: (message) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          },
          success: () {
            setState(() => _isLoading = false);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StartView()),
            );
          },
        );
      },
      child: PopScope(
        canPop: !_isLoading,
        child: ModalProgressHUD(
          inAsyncCall: _isLoading,
          opacity: 0.5,
          progressIndicator: const CircularProgressIndicator(),
          child: Scaffold(
            appBar: AppBar(
              title: Text(S.of(context).verify_phone),
              leading: _isLoading
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      S.of(context).enter_verification_code,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${S.of(context).sent_to} ${widget.phoneNumber}',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: S.of(context).verification_code,
                        border: const OutlineInputBorder(),
                        hintText: '••••••',
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: CustomButtonWidget(
                        text: S.of(context).verify,
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_otpController.text.length == 6) {
                                  context.read<SignupCubit>().verifyOtp(
                                        verificationId: widget.verificationId,
                                        smsCode: _otpController.text,
                                        phoneNumber: widget.phoneNumber,
                                        name: widget.name,
                                        age: widget.age,
                                        gender: widget.gender,
                                        password: widget.password,
                                      );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("رمز التحقق غير صحيح"),
                                    ),
                                  );
                                }
                              },
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              // Resend OTP functionality
                              context.read<SignupCubit>().signUpWithPhone(
                                    phoneNumber: widget.phoneNumber,
                                    name: widget.name,
                                    age: widget.age,
                                    gender: widget.gender,
                                    password: widget.password,
                                    confirmPassword: widget.password,
                                  );
                            },
                      child: Text(
                        S.of(context).resend_code,
                        style: TextStyle(
                          color: _isLoading
                              ? Colors.grey
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}