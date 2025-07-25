import 'package:flutter/material.dart';
import 'package:namaa/features/auth/singup/views/widgets/singup_form_widget.dart';

class SingupView extends StatelessWidget {
  const SingupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: SafeArea(
        child: SingupFormWidget(),
      ),
    );
  }
}
