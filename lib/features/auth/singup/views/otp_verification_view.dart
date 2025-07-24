import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namaa/cores/widgets/custom_button_widget.dart';
import 'package:namaa/features/auth/singup/view_model/cubit/signup_cubit.dart';
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

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).verify_phone)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              S.of(context).enter_verification_code,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).sent_to + widget.phoneNumber,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: S.of(context).verification_code,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            CustomButtonWidget(
              text: S.of(context).verify,
              onPressed: () {
                context.read<SignupCubit>().verifyOtp(
                  verificationId: widget.verificationId,
                  smsCode: _otpController.text,
                  phoneNumber: widget.phoneNumber,
                  name: widget.name,
                  age: widget.age,
                  gender: widget.gender,
                  password: widget.password,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
