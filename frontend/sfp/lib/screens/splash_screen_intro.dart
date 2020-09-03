import 'package:flutter/material.dart';
import 'package:sfp/assets.dart';
import 'package:sfp/screens/screens.dart';
import 'package:splashscreen/splashscreen.dart';

class SplashScreenIntro extends StatefulWidget {
  static const String route = '/';

  SplashScreenIntro({Key key}) : super(key: key);

  @override
  _SplashScreenIntroState createState() => _SplashScreenIntroState();
}

class _SplashScreenIntroState extends State<SplashScreenIntro> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 10,
      navigateAfterSeconds: LoginScreen(),
      title: Text(
        "Brought to you by the IT and OPS team\n UBA CI",
        style: const TextStyle(
          color: Assets.ubaRedColor,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
      image: Image.asset(Assets.ubaRedLogoT),
      photoSize: 100.0,
      loaderColor: Assets.ubaRedColor,
    );
  }
}
