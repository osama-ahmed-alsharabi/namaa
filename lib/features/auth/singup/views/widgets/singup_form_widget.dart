import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namaa/cores/utils/app_colors.dart';
import 'package:namaa/cores/widgets/custom_button_widget.dart';
import 'package:namaa/cores/widgets/text_field_form_widget.dart';
import 'package:namaa/features/auth/singup/view_model/cubit/signup_cubit.dart';
import 'package:namaa/features/auth/singup/views/otp_verification_view.dart';
import 'package:namaa/generated/l10n.dart';

class SingupFormWidget extends StatefulWidget {
  const SingupFormWidget({super.key});

  @override
  State<SingupFormWidget> createState() => _SingupFormWidgetState();
}

class _SingupFormWidgetState extends State<SingupFormWidget> {
  bool visibility = true;
  bool confirmVisibility = true;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignupCubit, SignupState>(
      listener: (context, state) {
        state.whenOrNull(
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          },
          codeSent: (verificationId, phoneNumber, name, age, gender, password) {
            // Navigate to OTP screen
            _navigateToOtpScreen(
              context,
              verificationId,
              phoneNumber,
              name,
              age,
              gender,
              password,
            );
          },
          success: () {
            // Navigate to home screen or show success message
            Navigator.of(context).pushReplacementNamed('/home');
          },
        );
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              textAlign: TextAlign.center,
              S.of(context).create_an_account,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 30),
      
            Text(
              S.of(context).name,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 5),
      
            TextFieldFormWidget(
              controller: _nameController,
              hint: S.of(context).name,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).age,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 5),
      
                      TextFieldFormWidget(
                        controller: _ageController,
                        hint: S.of(context).age,
                        keyboardType: TextInputType.number,
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
      
                      Text(
                        S.of(context).gender,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextFieldFormWidget(
                        controller: _genderController,
                        hint: S.of(context).gender,
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              S.of(context).phone_number,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 5),
            TextFieldFormWidget(
              controller: _phoneController,
              suffixText: "+966",
              keyboardType: TextInputType.phone,
              hint: S.of(context).phone_number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (value!.length < 9) return 'Invalid phone number';
                return null;
              },
            ),
            SizedBox(height: 15),
      
            Text(
              S.of(context).password,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 5),
            TextFieldFormWidget(
              controller: _passwordController,
              obscureText: visibility,
              suffix: GestureDetector(
                onTap: () {
                  visibility = !visibility;
                  setState(() {});
                },
                child: visibility
                    ? Icon(
                        Icons.visibility_off,
                        color: AppColors.primaryColor,
                      )
                    : Icon(Icons.visibility, color: AppColors.primaryColor),
              ),
              hint: S.of(context).password,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (value!.length < 6) return 'Password too short';
                return null;
              },
            ),
            SizedBox(height: 15),
      
            Text(
              S.of(context).confirm_password,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 5),
            TextFieldFormWidget(
              controller: _confirmPasswordController,
              obscureText: confirmVisibility,
              suffix: GestureDetector(
                onTap: () {
                  confirmVisibility = !confirmVisibility;
                  setState(() {});
                },
                child: confirmVisibility
                    ? Icon(
                        Icons.visibility_off,
                        color: AppColors.primaryColor,
                      )
                    : Icon(Icons.visibility, color: AppColors.primaryColor),
              ),
              hint: S.of(context).confirm_password,
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  S.of(context).you_dont_have_an_account,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    S.of(context).create_an_account,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: CustomButtonWidget(
                text: S.of(context).create_an_account,
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    context.read<SignupCubit>().signUpWithPhone(
                          phoneNumber: _phoneController.text,
                          name: _nameController.text,
                          age: _ageController.text,
                          gender: _genderController.text,
                          password: _passwordController.text,
                          confirmPassword: _confirmPasswordController.text,
                        );
                  }
                },
              ),
            ),
            SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  void _navigateToOtpScreen(
    BuildContext context,
    String verificationId,
    String phoneNumber,
    String name,
    String age,
    String gender,
    String password,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(
          verificationId: verificationId,
          phoneNumber: phoneNumber,
          name: name,
          age: age,
          gender: gender,
          password: password,
        ),
      ),
    );
  }
}