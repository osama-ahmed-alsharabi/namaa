
import 'package:flutter/material.dart';
import 'package:namaa/cores/utils/app_colors.dart';
import 'package:namaa/cores/widgets/custom_button_widget.dart';
import 'package:namaa/cores/widgets/text_field_form_widget.dart';
import 'package:namaa/generated/l10n.dart';

class SingupFormWidget extends StatefulWidget {
  const SingupFormWidget({
    super.key,
  });

  @override
  State<SingupFormWidget> createState() => _SingupFormWidgetState();
}

class _SingupFormWidgetState extends State<SingupFormWidget> {
    bool visibility = true;
  bool confirmVisibility = true;
  @override
  Widget build(BuildContext context) {
    return Form(
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
      
          TextFieldFormWidget(hint: S.of(context).name),
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
                      hint: S.of(context).age,
                      keyboardType: TextInputType.number,
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
                    TextFieldFormWidget(hint: S.of(context).gender),
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
            suffixText: "+966",
            keyboardType: TextInputType.number,
            hint: S.of(context).phone_number,
          ),
          SizedBox(height: 15),
      
          Text(
            S.of(context).password,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
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
                  ? Icon(
                      Icons.visibility_off,
                      color: AppColors.primaryColor,
                    )
                  : Icon(Icons.visibility, color: AppColors.primaryColor),
            ),
            hint: S.of(context).password,
          ),
          SizedBox(height: 15),
      
          Text(
            S.of(context).confirm_password,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
          ),
          SizedBox(height: 5),
          TextFieldFormWidget(
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
            child: CustomButtonWidget(text: S.of(context).register),
          ),
          SizedBox(height: 48),
        ],
      ),
    );
  }
}
