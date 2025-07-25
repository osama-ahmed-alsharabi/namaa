import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namaa/cores/utils/app_colors.dart';
import 'package:namaa/cores/widgets/custom_button_widget.dart';
import 'package:namaa/cores/widgets/text_field_form_widget.dart';
import 'package:namaa/features/auth/login/view_model/cubit/login_cubit.dart';
import 'package:namaa/features/auth/singup/views/signup_view.dart';
import 'package:namaa/features/home/views/home_view.dart';
import 'package:namaa/generated/l10n.dart';

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({super.key});

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  GlobalKey<FormState> keyForm = GlobalKey();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  bool visibility = true;

  // Controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        } else if (state is LoginSuccess) {
          // Navigate to home screen after successful login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeView()),
          );
        }
      },
      child: Form(
        key: keyForm,
        autovalidateMode: autovalidateMode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              textAlign: TextAlign.center,
              S.of(context).login,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 60),
            Text(
              S.of(context).phone_number,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 5),
            TextFieldFormWidget(
              controller: _phoneController,
              suffixText: "+966",
              keyboardType: TextInputType.phone,
              hint: S.of(context).phone_number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            Text(
              S.of(context).password,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
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
                    ? Icon(Icons.visibility_off, color: AppColors.primaryColor)
                    : Icon(Icons.visibility, color: AppColors.primaryColor),
              ),
              hint: S.of(context).password,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 5),
            Text(
              S.of(context).forget_password,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder<LoginCubit, LoginState>(
                builder: (context, state) {
                  if (state is LoginLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return CustomButtonWidget(
                    text: S.of(context).login,
                    onPressed: () {
                      if (keyForm.currentState!.validate()) {
                        final phoneNumber = _phoneController.text.trim();
                        final password = _passwordController.text.trim();
                        context.read<LoginCubit>().loginWithPhoneNumber(
                          phoneNumber,
                          password,
                        );
                      } else {
                        setState(() {
                          autovalidateMode = AutovalidateMode.always;
                        });
                      }
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  S.of(context).you_dont_have_an_account,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SingupView()),
                    );
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
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
