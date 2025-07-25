import 'package:flutter/material.dart';
import 'package:namaa/cores/utils/app_colors.dart';

class TextFieldFormWidget extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final Widget? suffix;
  final String? suffixText;
  final bool? obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  const TextFieldFormWidget({
    super.key,
    this.controller,
    required this.hint,
    this.suffix,
    this.suffixText,
    this.obscureText,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      keyboardType: keyboardType,
      controller: controller,
      obscureText: obscureText ?? false,
      cursorColor: AppColors.primaryColor,
      decoration: InputDecoration(
        suffixText: suffixText,
        suffixIcon: suffix,
        hint: Text(hint),
        enabledBorder: border(),
        errorBorder: border(color: Colors.red),
        focusedErrorBorder: border(color: Colors.red),
        focusedBorder: border(),
      ),
    );
  }

  OutlineInputBorder border({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color ?? AppColors.primaryColor, width: 2),
    );
  }
}
