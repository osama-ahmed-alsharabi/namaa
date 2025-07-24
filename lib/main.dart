import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:namaa/cores/utils/app_colors.dart';
import 'package:namaa/features/splash/view/splash_view.dart';
import 'package:namaa/generated/l10n.dart';

void main() {
  runApp(const Namaa());
}

class Namaa extends StatelessWidget {
  const Namaa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: false,
        iconTheme: IconThemeData(
          color: AppColors.primaryColor
        ),
        scaffoldBackgroundColor: Color(0xffFFFEF9),
        appBarTheme: AppBarTheme(
          backgroundColor:  Color(0xffFFFEF9),
          iconTheme: IconThemeData(
            color: Colors.black
          )
        )
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
    );
  }
}
