import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sfp/assets.dart';
import 'package:sfp/src/screens/screens.dart';
import 'package:splashscreen/splashscreen.dart';

class SplashScreenIntro extends StatefulWidget {
  static const String route = '/';

  SplashScreenIntro({Key key}) : super(key: key);

  @override
  _SplashScreenIntroState createState() => _SplashScreenIntroState();
}

class _SplashScreenIntroState extends State<SplashScreenIntro>
    with SingleTickerProviderStateMixin {
  Animation _fadeOut;
  AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    Timer(Duration(seconds: 2), () {
      _fadeCtrl.forward();
    });
  }

  @override
  dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: FadeTransition(
        opacity: _fadeOut,
        child: SplashScreen(
          seconds: 3,
          navigateAfterSeconds: HomeScreen(),
          title: Text(
            "\n\nSuper File Processor\n\n\nBrought to you by the IT and OPS team\n UBA CI",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Assets.ubaRedColor,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          image: Image.asset(
            Assets.ubaRedLogoT,
            fit: BoxFit.cover,
          ),
          photoSize: 100.0,
          loaderColor: Assets.ubaRedColor,
        ),
      ),
    );
  }
}
