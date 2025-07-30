import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namaa/features/auth/login/view_model/cubit/login_cubit.dart';
import 'package:namaa/features/auth/login/views/widgets/login_form_widget.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFEF9),
      appBar: AppBar(elevation: 0,
      backgroundColor: Color(0xffFFFEF9),
      ),
      body: SafeArea(
        child: BlocProvider(
          create: (context) => LoginCubit(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LoginFormWidget(),
            ),
          ),
        ),
      ),
    );
  }
}