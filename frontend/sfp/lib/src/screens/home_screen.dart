import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:sfp/assets.dart';
import 'package:sfp/src/blocs/blocs.dart';
import 'package:sfp/src/screens/screens.dart';
import 'package:sfp/src/widgets/pdf_viewer.dart';
import 'package:sfp/src/widgets/widgets.dart';
import 'package:sfp/utils.dart';

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
  AlertBloc alertBloc;
  DocBloc docBloc;
  FToast ftoast;

  bool isIntitialPage = true;
  Animation _fadeIn;
  AnimationController _fadeCtrl;
  Animation _subSlide, _subFadeIn;
  AnimationController _subSlideController;
  int currentPdfPage = 0;
  int totalPdfPages = 0;

  @override
  void initState() {
    super.initState();
    animationBloc = context.bloc<AnimateEntranceBloc>();
    navBloc = context.bloc<NavBloc>();
    authBloc = context.bloc<AuthBloc>();
    dataBloc = context.bloc<DataBloc>();
    docBloc = context.bloc<DocBloc>();
    alertBloc = context.bloc<AlertBloc>();
    _fadeCtrl =
        AnimationController(duration: Duration(milliseconds: 400), vsync: this);
    _subSlideController =
        AnimationController(duration: Duration(milliseconds: 400), vsync: this);
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
    _fadeCtrl.dispose();
    _subSlideController.dispose();
    super.dispose();
  }

  void _showAlert(
      {bool isAlertUp = false,
      BuildContext context,
      Widget leWidget,
      String title = '',
      List<Widget> actions,
      Alignment alignement,
      bool isDoc,
      Uint8List doc}) {
    if (!isAlertUp) {
      Utils.log('closing the displayed alert dialog');
      Navigator.of(context).pop();
      return;
    }

    showDialog(
        context: context,
        barrierDismissible: alignement != null,
        builder: (context) {
          if (alignement != null) {
            Utils.log('custom alert box');

            return Stack(children: [
              alignement == Alignment.bottomRight
                  ? Positioned(right: 20.0, bottom: 100.0, child: leWidget)
                  : Positioned(child: leWidget)
            ]);
          } else if (isDoc) {
            var _pdfController =
                PdfController(document: PdfDocument.openData(doc));
            Utils.log(' document is here to show');

            return StatefulBuilder(
              builder: (context, setState) {
                return BlocListener<DocBloc, DocState>(
                  listener: (context, state) {
                    Utils.log(
                        "current state is $state and page is ${docBloc.currentPage}");
                    if (state is ChangePage) {
                      setState(() {
                        currentPdfPage = docBloc.currentPage;
                        totalPdfPages = docBloc.totalPages;
                      });
                    }
                  },
                  child: AlertDialog(
                    title: Text(title),
                    content: PdfViewer(
                      controller: _pdfController,
                    ),
                    actions: actions,
                  ),
                );
              },
            );
          } else {
            Utils.log('no document here to show');
            return AlertDialog(
              title: Text(title),
              content: leWidget,
              actions: actions,
            );
          }
        });
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
              child: BlocListener<AlertBloc, AlertState>(
                listener: (context, state) {
                  if (state.status == AlertDialogStatus.opened) {
                    _showAlert(
                        isAlertUp: true,
                        context: context,
                        isDoc: state.isDoc,
                        doc: state.doc,
                        leWidget: state.whatToShow,
                        title: state.title,
                        actions: state.actions,
                        alignement: state.alignement);
                  } else if (state.status == AlertDialogStatus.closed) {
                    _showAlert(isAlertUp: false, context: context, actions: []);
                  }
                },
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state.status == AuthStatus.authenticated) {
                      return CustomAppBar(
                        helpOnPressed: () => Utils.log('Help pressed'),
                        logOut: () {
                          authBloc.add(LogOut());
                        },
                        userConnected: true,
                      );
                    } else {
                      //the user should be directed to the login page
                      if (state.status == AuthStatus.unknown &&
                          !isIntitialPage) {
                        Timer(Duration(milliseconds: 100), () {
                          animationBloc.add(LeavingPage());
                          dataBloc.add(FetchConfigs());
                          Timer(Duration(milliseconds: 500), () {
                            navBloc.add(GoLogin());
                          });
                        });
                      }
                      return CustomAppBar(
                        helpOnPressed: () => Utils.log('Help pressed'),
                        logOut: () => authBloc.add(LogOut()),
                        userConnected: false,
                      );
                    }
                  },
                ),
              ),
              preferredSize:
                  Size(screenSize.width, AppBar().preferredSize.height),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Assets.ubaRedColor,
              child: const Icon(Icons.feedback),
              tooltip: "Is something wrong ? Contact IT Support",
              onPressed: () => Utils.log('Should display support popup'),
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
