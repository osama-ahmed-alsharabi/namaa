import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:namaa/cores/utils/app_colors.dart';
import 'package:namaa/cores/widgets/custom_button_widget.dart';
import 'package:namaa/cores/widgets/text_field_form_widget.dart';
import 'package:namaa/features/auth/singup/view_model/cubit/signup_cubit.dart';
import 'package:namaa/features/auth/singup/views/otp_verification_view.dart';
import 'package:namaa/features/start_page/start_view.dart';
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
  bool _isLoading = false;

  final List<String> genders = ['أنثى', 'ذكر'];
  String? selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    selectedGender = genders[0];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignupCubit, SignupState>(
      listener: (context, state) {
        state.whenOrNull(
          loading: () => setState(() => _isLoading = true),
          error: (message) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          },
          codeSent: (verificationId, phoneNumber, name, age, gender, password) {
            setState(() => _isLoading = false);
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
            setState(() => _isLoading = false);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const StartView()),
            );
          },
        );
      },
      builder: (context, state) {
        return PopScope(
          canPop: !_isLoading,
          child: ModalProgressHUD(
            inAsyncCall: _isLoading,
            progressIndicator: CircularProgressIndicator(
              color: AppColors.brownColor,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        textAlign: TextAlign.center,
                        S.of(context).create_an_account,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 30),

                      Text(
                        S.of(context).name,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 5),

                      TextFieldFormWidget(
                        controller: _nameController,
                        hint: S.of(context).name,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  S.of(context).age,
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 5),

                                TextFieldFormWidget(
                                  controller: _ageController,
                                  hint: S.of(context).age,
                                  keyboardType: TextInputType.number,
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? 'مطلوب' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),

                                // داخل عمود الجنس (استبدل الـ TextFieldFormWidget بالجديد):
                                Text(
                                  S.of(context).gender,
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                DropdownButtonFormField<String>(
                                  value: selectedGender,
                                  items: genders.map((g) {
                                    return DropdownMenuItem(
                                      value: g,
                                      child: Text(g),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      selectedGender = val!;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 10,
                                    ),
                                  ),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? 'مطلوب'
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        S.of(context).phone_number,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextFieldFormWidget(
                        controller: _phoneController,
                        suffixText: "+966",
                        keyboardType: TextInputType.phone,
                        hint: S.of(context).phone_number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'مطلوب';
                          if (value!.length < 9) return 'رقم الجوال غير صالح';
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      Text(
                        S.of(context).password,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextFieldFormWidget(
                        controller: _passwordController,
                        obscureText: visibility,
                        suffix: GestureDetector(
                          onTap: () {
                            setState(() => visibility = !visibility);
                          },
                          child: Icon(
                            visibility
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        hint: S.of(context).password,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'مطلوب';
                          if (value!.length < 6) return 'كلمة السر صغيرة';
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      Text(
                        S.of(context).confirm_password,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextFieldFormWidget(
                        controller: _confirmPasswordController,
                        obscureText: confirmVisibility,
                        suffix: GestureDetector(
                          onTap: () {
                            setState(
                              () => confirmVisibility = !confirmVisibility,
                            );
                          },
                          child: Icon(
                            confirmVisibility
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        hint: S.of(context).confirm_password,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'كلمة السر غير متطابقة';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            S.of(context).you_dont_have_an_account,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () => Navigator.pop(context),
                            child: Text(
                              S.of(context).create_an_account,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: _isLoading ? Colors.grey : Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: CustomButtonWidget(
                          text: S.of(context).create_an_account,
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    context.read<SignupCubit>().signUpWithPhone(
                                      phoneNumber: _phoneController.text,
                                      name: _nameController.text,
                                      age: _ageController.text,
                                      gender: _genderController.text,
                                      password: _passwordController.text,
                                      confirmPassword:
                                          _confirmPasswordController.text,
                                    );
                                  }
                                },
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
