import 'package:flutter/material.dart';
import 'package:namaa/cores/assets.dart';
import 'package:namaa/features/onboarding/onboarding_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    delay3Seconds();
    super.initState();
  }

  delay3Seconds() async {
    await Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingView()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xffFFFEF9),
      body: Center(child: Image.asset(Assets.imagesLogo)),
    );
  }
}
