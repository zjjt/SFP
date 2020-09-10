import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfp/assets.dart';
import 'package:sfp/src/blocs/blocs.dart';
import 'package:sfp/src/widgets/widgets.dart';

class SelectConfigPage extends StatefulWidget {
  SelectConfigPage({Key key}) : super(key: key);

  @override
  _SelectConfigPageState createState() => _SelectConfigPageState();
}

class _SelectConfigPageState extends State<SelectConfigPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  Animation _radioSlide, _radioFadeIn;
  AnimationController _radioSlideController;
  AuthBloc authBloc;
  NavBloc navBloc;
  DataBloc dataBloc;
  AnimateEntranceBloc animateBloc;
  int selectedConfigIndex;
  String description;
  bool isError = false;
  @override
  void initState() {
    super.initState();
    // ignore: close_sinks
    selectedConfigIndex = -1;
    description = '';
    authBloc = context.bloc<AuthBloc>();
    navBloc = context.bloc<NavBloc>();
    dataBloc = context.bloc<DataBloc>();
    animateBloc = context.bloc<AnimateEntranceBloc>();
    //launching entrence animation
    animateBloc.add(EnteringPage());
    _radioSlideController =
        AnimationController(duration: Duration(milliseconds: 800), vsync: this);
    _radioFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _radioSlideController, curve: Curves.easeOut));
    _radioSlide = Tween<Offset>(begin: const Offset(3, 0.0), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _radioSlideController, curve: Curves.easeOut));
    Timer(Duration(milliseconds: 200), () {
      _radioSlideController.forward();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _radioSlideController.dispose();
  }

  void _setConfig(int value) {
    setState(() {
      selectedConfigIndex = value;
      description = dataBloc.processConfigs[value].description;
    });
  }

  void _proceed() {
    if (selectedConfigIndex >= 0) {
      setState(() {
        isError = false;
        description = dataBloc.processConfigs[selectedConfigIndex].description;
        dataBloc.add(SelectConfig(selectedConfigIndex));
        Timer(Duration(milliseconds: 100), () {
          animateBloc.add(LeavingPage());
          Timer(Duration(milliseconds: 500), () {
            navBloc.add(GoFupload());
          });
        });
      });
    } else {
      setState(() {
        isError = true;
        description =
            "Please choose one of the options above before proceeding";
      });
    }
    //go to next page which is fileUpload
  }

  @override
  Widget build(BuildContext context) {
    Size appB = Size(
        Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width / 3.0
            : MediaQuery.of(context).size.width,
        80.0);
    return Container(
      width: appB.width,
      //height: 500,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 150.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "What task do you want to process ?",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Assets.ubaRedColor,
                      fontSize: 50.0,
                    ),
                  ),
                  SizedBox(height: 50.0),
                  Container(
                    padding: Responsive.isMobile(context)
                        ? const EdgeInsets.symmetric(horizontal: 30.0)
                        : const EdgeInsets.all(0),
                    child: Container(
                      child: Column(
                        children: [
                          SlideTransition(
                            position: _radioSlide,
                            child: FadeTransition(
                              opacity: _radioFadeIn,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (dataBloc.processConfigs != null)
                                    for (int i = 0;
                                        i < dataBloc.processConfigs.length;
                                        i++)
                                      Container(
                                        child: Row(
                                          children: [
                                            Radio(
                                              activeColor: Assets.ubaRedColor,
                                              groupValue: selectedConfigIndex,
                                              value: i,
                                              hoverColor: Colors.red,
                                              onChanged: (value) {
                                                print(
                                                    'selected ${dataBloc.processConfigs[value]}');
                                                _setConfig(value);
                                              },
                                              //selected: false,
                                            ),
                                            SizedBox(width: 10.0),
                                            Text(
                                                dataBloc.processConfigs[i]
                                                    .configName,
                                                style: const TextStyle(
                                                    color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 40.0),
                          Container(
                            width: appB.width * 0.5,
                            height: 40.0,
                            child: BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                              return RaisedButton(
                                onPressed: _proceed,
                                color: Assets.ubaRedColor,
                                hoverColor: Colors.black,
                                textColor: Colors.white,
                                child: Text("Proceed",
                                    style: const TextStyle(fontSize: 16)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: 20.0),
                          Container(
                            child: Center(
                              child: Text(
                                description,
                                textAlign: TextAlign.center,
                                softWrap: true,
                                style: TextStyle(
                                    color: isError
                                        ? Assets.ubaRedColor
                                        : Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
