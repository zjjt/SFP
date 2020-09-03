import 'package:flutter/material.dart';
import 'package:sfp/assets.dart';
import 'package:sfp/screens/screens.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super File Processor',
      theme: ThemeData(
          primarySwatch: Assets.ubaRedColor,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.white),
      initialRoute: SplashScreenIntro.route,
      routes: {
        SplashScreenIntro.route: (context) => SplashScreenIntro(),
        LoginScreen.route: (context) => LoginScreen(),
      },
    );
  }
}
