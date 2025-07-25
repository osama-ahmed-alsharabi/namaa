import 'package:flutter/material.dart';
import 'package:namaa/cores/utils/app_colors.dart';
import 'package:namaa/cores/widgets/custom_button_widget.dart';
import 'package:namaa/cores/widgets/text_field_form_widget.dart';

class YourMonthlyBudgetView extends StatelessWidget {
  const YourMonthlyBudgetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10),
              Text(
                " ميزانيتك الشهرية ",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Text(
                "خطّط لميزانيتك، وابدأ بصناعة الفارق في نمائك المالي!",
                style: TextStyle(fontSize: 15, color: AppColors.primaryColor),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: CustomButtonWidget(
                        height: 60,
                        text: 'وزّع ميزانيتك حسب أولوياتك ',
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.brownColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Text("الإدخار : "),
                    SizedBox(width: 10),
                    Expanded(child: TextFieldFormWidget(hint: '')),
                  ],
                ),
              ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.2,),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: CustomButtonWidget(height: 40, text: "تعديل"),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: CustomButtonWidget(height: 40, text: "حفظ "),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: CustomButtonWidget(
                  height: 60,
                  text: "التالي"),
              ),
              SizedBox(height: 20,)
            ],
          ),
        ),
      ),
    );
  }
}
