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

class _ResultPageState extends State<ResultPage> {
  DataBloc dataBloc;
  AnimateEntranceBloc animateBloc;
  @override
  void initState() {
    super.initState();
    dataBloc = context.bloc<DataBloc>();
    animateBloc = context.bloc<AnimateEntranceBloc>();
    //launching entrence animation
    animateBloc.add(EnteringPage());
  }

  @override
  Widget build(BuildContext context) {
    Size appB = Size(MediaQuery.of(context).size.width, 80.0);
    return Container(
      width: appB.width,
      color: Colors.blue,
      //height: 500,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 150.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "File processing control",
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
                    child: Column(
                      children: [
                        for (int i = 0; i < dataBloc.processedFiles.length; i++)
                          if (dataBloc.processedFiles[i].inFile !=
                              null /*&&
                              dataBloc.processedFiles[i].outFile != null*/
                          )
                            Container(
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
                                                    BorderRadius.circular(
                                                        20.0)),
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
                                                  size: Responsive.isMobile(
                                                          context)
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
                                                    BorderRadius.circular(
                                                        20.0)),
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
                                  Text("File ${++i}"),
                                  Divider(),
                                ],
                              ),
                            ),
                      ],
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
