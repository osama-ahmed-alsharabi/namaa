import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namaa/cores/assets.dart';
import 'package:namaa/cores/widgets/custom_button_widget.dart';
import 'package:namaa/features/auth/login/views/login_view.dart';
import 'package:namaa/features/auth/singup/view_model/cubit/signup_cubit.dart';
import 'package:namaa/features/auth/singup/views/sighup_view.dart';
import 'package:namaa/generated/l10n.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocProvider(
          create: (context) => SignupCubit(),
          child: Column(
            children: [
              Image.asset(Assets.imagesNamaa),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginView()),
                        );
                      },
                      child: CustomButtonWidget(text: S.of(context).login),
                    ),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SingupView()),
                        );
                      },
                      child: CustomButtonWidget(
                        text: S.of(context).create_an_account,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
