import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfp/assets.dart';
import 'package:sfp/src/blocs/blocs.dart';
import 'package:sfp/src/screens/screens.dart';
import 'package:sfp/src/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  static const String route = '/login';

  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  AnimateEntranceBloc animationBloc;
  NavBloc navBloc;
  AuthBloc authBloc;
  DataBloc dataBloc;
  bool isIntitialPage = true;
  Animation _fadeIn;
  AnimationController _fadeCtrl;
  Animation _subSlide, _subFadeIn;
  AnimationController _subSlideController;
  @override
  void initState() {
    super.initState();
    animationBloc = context.bloc<AnimateEntranceBloc>();
    navBloc = context.bloc<NavBloc>();
    authBloc = context.bloc<AuthBloc>();
    dataBloc = context.bloc<DataBloc>();
    _fadeCtrl =
        AnimationController(duration: Duration(milliseconds: 400), vsync: this);
    _subSlideController =
        AnimationController(duration: Duration(milliseconds: 800), vsync: this);
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _subFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _subSlideController, curve: Curves.easeOut));
    _subSlide = Tween<Offset>(begin: const Offset(0.0, -0.5), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _subSlideController, curve: Curves.easeOut));
    Timer(Duration(milliseconds: 100), () {
      _fadeCtrl.forward();
    });

    _subSlideController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationBloc.add(SignalEndAnimation());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _fadeCtrl.dispose();
    _subSlideController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return FadeTransition(
      opacity: _fadeIn,
      child: Container(
        child: BlocListener<NavBloc, NavState>(
          listener: (context, state) {
            if (state is LoginState) {
              setState(() {
                isIntitialPage = true;
              });
            } else {
              setState(() {
                isIntitialPage = false;
              });
            }
          },
          child: Scaffold(
            appBar: PreferredSize(
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state.status == AuthStatus.authenticated) {
                    return CustomAppBar(
                      helpOnPressed: () => print('Help pressed'),
                      logOut: () {
                        authBloc.add(LogOut());
                      },
                      userConnected: true,
                    );
                  } else {
                    //the user should be directed to the login page
                    if (state.status == AuthStatus.unknown && !isIntitialPage) {
                      Timer(Duration(milliseconds: 100), () {
                        animationBloc.add(LeavingPage());
                        dataBloc.add(FetchConfigs());
                        Timer(Duration(milliseconds: 500), () {
                          navBloc.add(GoLogin());
                        });
                      });
                    }
                    return CustomAppBar(
                      helpOnPressed: () => print('Help pressed'),
                      logOut: () => authBloc.add(LogOut()),
                      userConnected: false,
                    );
                  }
                },
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
                      child: BlocListener<AnimateEntranceBloc,
                          AnimateEntranceState>(
                        listener: (context, state) {
                          //we animate the entrance and leaving animations of each subPages
                          switch (state.status) {
                            case AnimationEntranceStatus.unknown:
                              break;
                            case AnimationEntranceStatus.start:
                              //start animating forward
                              //reset values to their proper point by dispatching AnimationEntranceStatus.done
                              _subSlideController.reset();
                              _subSlideController.forward();
                              break;
                            case AnimationEntranceStatus.reverse:
                              //start animating backward
                              //reset values to their proper point by dispatching AnimationEntranceStatus.done
                              _subSlideController.reverse();
                              break;
                            case AnimationEntranceStatus.done:
                              //_subSlideController.reset();
                              break;
                          }
                        },
                        child: SlideTransition(
                            position: _subSlide,
                            child: FadeTransition(
                              opacity: _subFadeIn,
                              child: PageBuilder(),
                            )),
                      ),
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
      ),
    );
  }
}
