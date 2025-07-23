import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
