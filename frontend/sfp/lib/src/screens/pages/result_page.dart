import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfp/assets.dart';
import 'package:sfp/src/blocs/blocs.dart';
import 'package:sfp/src/widgets/widgets.dart';

class ResultPage extends StatefulWidget {
  ResultPage({Key key}) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> with TickerProviderStateMixin {
  DataBloc dataBloc;
  AnimateEntranceBloc animateBloc;
  AlertBloc alertBloc;
  NavBloc navBloc;
  @override
  void initState() {
    super.initState();
    dataBloc = context.bloc<DataBloc>();
    animateBloc = context.bloc<AnimateEntranceBloc>();
    alertBloc = context.bloc<AlertBloc>();
    navBloc = context.bloc<NavBloc>();
    //launching entrence animation
    animateBloc.add(EnteringPage());
  }

  @override
  Widget build(BuildContext context) {
    Size appB = Size(MediaQuery.of(context).size.width, 80.0);
    return Container(
      width: appB.width,
      //height: 500,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${dataBloc.currentConfig.configName == "CANAL" ? 'CANAL+' : dataBloc.currentConfig.configName}\nFile processing control",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Assets.ubaRedColor,
                      fontSize: 50.0,
                    ),
                  ),
                  SizedBox(height: 50.0),
                  BlocListener<DataBloc, DataState>(
                    listener: (context, state) {
                      if (state is AllFilesDiscarded) {
                        Timer(Duration(milliseconds: 100), () {
                          animateBloc.add(LeavingPage());
                          Timer(Duration(milliseconds: 500), () {
                            navBloc.add(GoFupload());
                          });
                        });
                      }
                      if (state is FilesDiscarded && !state.errors) {
                        setState(() {
                          print("updating file list UI");
                        });
                      }
                    },
                    child: Container(
                      padding: Responsive.isMobile(context)
                          ? const EdgeInsets.symmetric(horizontal: 30.0)
                          : const EdgeInsets.all(0),
                      child: Column(
                        children:
                            List.generate(dataBloc.processedFiles.length, (i) {
                          print(dataBloc.processedFiles[i].inFile.runtimeType);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.grey[200])),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      height: Responsive.isMobile(context)
                                          ? 150
                                          : 200,
                                      width: Responsive.isMobile(context)
                                          ? 150
                                          : 200,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20.0)),
                                      child: Tooltip(
                                        message:
                                            "click to see the initial file you uploaded",
                                        child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0)),
                                          onPressed: () {},
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.description_outlined,
                                                color: Assets.ubaRedColor,
                                                size:
                                                    Responsive.isMobile(context)
                                                        ? 50
                                                        : 80,
                                              ),
                                              SizedBox(
                                                height: 20.0,
                                              ),
                                              Text(
                                                "Initial file",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize:
                                                        Responsive.isMobile(
                                                                context)
                                                            ? 14.0
                                                            : 20.0,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      height: Responsive.isMobile(context)
                                          ? 150
                                          : 200,
                                      width: Responsive.isMobile(context)
                                          ? 150
                                          : 200,
                                      child: Tooltip(
                                        message:
                                            "click to see the new file generated after processing ",
                                        child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0)),
                                          onPressed: () {},
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(Icons.description_outlined,
                                                  color: Assets.ubaRedColor,
                                                  size: Responsive.isMobile(
                                                          context)
                                                      ? 50
                                                      : 80),
                                              SizedBox(
                                                height: 20.0,
                                              ),
                                              Text(
                                                "Processed file",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize:
                                                        Responsive.isMobile(
                                                                context)
                                                            ? 14.0
                                                            : 20.0,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("File ${i + 1}"),
                                    SizedBox(width: 50.0),
                                    IconButton(
                                      color: Colors.black,
                                      tooltip: "Discard this file ?",
                                      icon: Icon(Icons.highlight_off),
                                      onPressed: () => alertBloc.add(ShowAlert(
                                        title: "Discard this file ?",
                                        whatToShow: Text(
                                            "Do you really want to discard this file ? the file will be removed from the processing pipeline."),
                                        actions: [
                                          FlatButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text("CANCEL",
                                                      style: const TextStyle(
                                                          color:
                                                              Colors.black)))),
                                          FlatButton(
                                              onPressed: () {
                                                print("i index $i");
                                                Navigator.of(context).pop();
                                                dataBloc.add(DiscardFiles(
                                                    files: [
                                                      dataBloc.processedFiles[i]
                                                    ]));
                                              },
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text("DISCARD IT")))
                                        ],
                                      )),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
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
