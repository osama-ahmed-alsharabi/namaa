import 'package:flutter/material.dart';
import 'package:namaa/cores/widgets/custom_bottom_navigation_bar.dart';
import 'package:namaa/cores/widgets/custom_button_widget.dart';
import 'package:namaa/features/delete_account/delete_account_view.dart';
import 'package:namaa/features/goal/goal_view.dart';
import 'package:namaa/features/your_monthly_budget/your_monthly_budget_view.dart';

class SettingsView extends StatelessWidget {
  static const String settings= "settings";
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Text(
              "اللإعدادات",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  CustomButtonWidget(text: "عن نماء"),
                  SizedBox(height: 20),
                  CustomButtonWidget(
                    onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>GoalView(
                          isEdting: true,
                        )));
                    
                    },
                    text: "تعديل بياناتك المالية"),
                  SizedBox(height: 20),
                  CustomButtonWidget(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>YourMonthlyBudgetView(
                        isEditing: true,
                      )));
                    },
                    text: "تعديل ميزانيتك الشهرية"),
                  SizedBox(height: 20),
                  CustomButtonWidget(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>DeleteAccountView()));
                    },
                    text: "حذف الحساب "),
                ],
              ),
            ),
            Spacer(),
            CustomBottomNavigationBar(
              pageName: settings,
            )
          ],
        ),
      ),
    );
  }
}
