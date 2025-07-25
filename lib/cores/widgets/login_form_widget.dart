import 'package:flutter/material.dart';
import 'package:namaa/cores/utils/app_colors.dart';
import 'package:namaa/cores/widgets/custom_button_widget.dart';
import 'package:namaa/cores/widgets/text_field_form_widget.dart';
import 'package:namaa/features/auth/singup/views/signup_view.dart';
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
  @override
  Widget build(BuildContext context) {
    return Form(
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
            suffixText: "+966",
            keyboardType: TextInputType.number,
            hint: S.of(context).phone_number,
          ),
          SizedBox(height: 20),
          Text(
            S.of(context).password,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
          ),
          SizedBox(height: 5),
          TextFieldFormWidget(
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
          ),
          SizedBox(height: 5),

          Text(
            S.of(context).forget_password,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          ),

          SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomButtonWidget(text: S.of(context).login),
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
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>SingupView()));
                },
                child: Text(
                  S.of(context).create_an_account,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400 , color: Colors.blue),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
