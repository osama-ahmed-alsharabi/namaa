import 'package:flutter/material.dart';
import 'package:namaa/cores/assets.dart';
import 'package:namaa/cores/utils/app_colors.dart';
import 'package:namaa/cores/widgets/custom_button_widget.dart';
import 'package:namaa/features/goal/goal_view.dart';

class StartView extends StatelessWidget {
  const StartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 30,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                "جاهز تخطط لهدفك الجاي مع درهم ؟"
                " يلا نبدأ سوا !",
                textAlign: TextAlign.center,
                style: TextStyle( 
                  fontWeight: FontWeight.bold,
                  fontSize: 30 , color: AppColors.primaryColor, ),
              ),
            ),
            SizedBox(height: 10,),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Image.asset(Assets.imagesTest)),
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: CustomButtonWidget(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>GoalView()));
                },
                text: "جاهز!"),
            ),
            SizedBox(height: 40,)
          ],
        ),
      ),
    );
  }
}
