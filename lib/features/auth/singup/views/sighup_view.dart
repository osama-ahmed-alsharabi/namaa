import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namaa/features/auth/singup/view_model/cubit/signup_cubit.dart';
import 'package:namaa/features/auth/singup/views/widgets/singup_form_widget.dart';

class SingupView extends StatelessWidget {
  const SingupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: BlocProvider(
        create: (context) => SignupCubit(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingupFormWidget(),
            ),
          ),
        ),
      ),
    );
  }
}
