import 'package:flutter/material.dart';
import 'package:namaa/cores/utils/app_colors.dart';
import 'package:namaa/cores/widgets/custom_button_widget.dart';
import 'package:namaa/cores/widgets/text_field_form_widget.dart';

class GoalView extends StatelessWidget {
  const GoalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "هدفك مع نَماء ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: TextFieldFormWidget(
                  hint: 'وش الهدف الي تبي توصلة؟',
                  keyboardType: TextInputType.number,
                ),
              ),
          
              SizedBox(height: 15),
              Text(
                "دخلك الشهري ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: TextFieldFormWidget(
                  hint: "كم دخلك شهريا",
                  keyboardType: TextInputType.number,
                ),
              ),
          
              SizedBox(height: 15),
              Text(
                "مصروفك اليومي",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: TextFieldFormWidget(
                  hint: "كم تصرف كل يوم",
                  keyboardType: TextInputType.number,
                ),
              ),
          
              SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80.0),
                child: CustomButtonWidget(text: "التالي"),
              ),
              SizedBox(height: 48,)
            ],
          ),
        ),
      ),
    );
  }
}
