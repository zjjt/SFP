import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sfp/assets.dart';
import 'package:sfp/src/screens/pages/pages.dart';
import 'package:sfp/src/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  static const String route = '/login';

  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  Animation _fadeIn;
  AnimationController _fadeCtrl;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fadeCtrl =
        AnimationController(duration: Duration(milliseconds: 400), vsync: this);
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    Timer(Duration(milliseconds: 100), () {
      _fadeCtrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return FadeTransition(
      opacity: _fadeIn,
      child: Container(
        child: Scaffold(
          appBar: PreferredSize(
            child: CustomAppBar(
              helpOnPressed: () => print('Help pressed'),
              logOut: () => print('loging out pressed'),
            ),
            preferredSize:
                Size(screenSize.width, AppBar().preferredSize.height),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Assets.ubaRedColor,
            child: const Icon(Icons.feedback),
            tooltip: "Is something wrong ? Contact IT Support",
            onPressed: () => print('Should display support popup'),
          ),
          body: Container(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: LoginPage(),
                  ),
                ),
                //Spacer(),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Text("SFP v1.0.0 ubagroup.com")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
