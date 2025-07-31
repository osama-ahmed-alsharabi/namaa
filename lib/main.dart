import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:namaa/cores/utils/app_colors.dart';
import 'package:namaa/features/auth/singup/view_model/cubit/signup_cubit.dart';
import 'package:namaa/features/chat/view_model/cubit/chat_cubit.dart';
import 'package:namaa/features/home/views/home_view.dart';
import 'package:namaa/features/splash/view/splash_view.dart';
import 'package:namaa/features/stats/view_model/goal_monthly_cubit/goal_stats_cubit.dart';
import 'package:namaa/features/ticker/ticker_view.dart';
import 'package:namaa/features/your_monthly_budget/view_model/cubit/monthly_budget_cubit.dart';
import 'package:namaa/firebase_options.dart';
import 'package:namaa/generated/l10n.dart';

String? userIdOfApp;

List<String> imagesApp = [];
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const Namaa());
}


class Namaa extends StatelessWidget {
  const Namaa({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SignupCubit()),
        BlocProvider(create: (context) => BudgetCubit()),
        BlocProvider(create: (context) => ChatCubit()),
        BlocProvider(create: (context) => HomeCubit()),
        BlocProvider(
          create: (context) => GoalMonthlyCubit(userIdOfApp: userIdOfApp!),
        ),
        BlocProvider(create: (context) => GameCubit(userIdOfApp!)),
      ],
      child: MaterialApp(
        theme: ThemeData(
          iconTheme: IconThemeData(color: AppColors.primaryColor),
          appBarTheme: AppBarTheme(
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
          ),
        ),
        debugShowCheckedModeBanner: false,
        locale: Locale("ar"),
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: SplashView(),
      ),
    );
  }
}
