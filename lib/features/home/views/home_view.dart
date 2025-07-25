import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:namaa/cores/assets.dart';
import 'package:namaa/cores/utils/app_colors.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    SvgPicture.asset(Assets.imagesUser),
                    Spacer(),
                    SvgPicture.asset(Assets.imagesEye),
                    SizedBox(width: 10),
                    SvgPicture.asset(Assets.imagesLogout),
                  ],
                ),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 80, left: 20),
                        child: Image.asset(Assets.imagesMessage),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20, left: 80),
                        child: Image.asset(Assets.imagesTest),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 32),
                child: Image.asset(Assets.imagesCard),
              ),
              SizedBox(height: 20,),
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.brownColor
                ),
                child: Row(
                  children: [
                    
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
