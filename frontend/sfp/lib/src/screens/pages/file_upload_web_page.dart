import 'dart:async';

import 'package:file_picker/file_picker.dart'
    if (dart.library.html) 'package:file_picker_web/file_picker_web.dart';
import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sfp/assets.dart';
import 'package:sfp/src/blocs/blocs.dart';
import 'package:sfp/src/widgets/widgets.dart';
import 'package:universal_html/html.dart' as html;

class FileUploadWebPage extends StatefulWidget {
  FileUploadWebPage({Key key}) : super(key: key);

  @override
  _FileUploadWebPageState createState() => _FileUploadWebPageState();
}

class _FileUploadWebPageState extends State<FileUploadWebPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  Animation _uploadSlide, _uploadFadeIn;
  AnimationController _uploadSlideController;
  AuthBloc authBloc;
  NavBloc navBloc;
  DataBloc dataBloc;
  AlertBloc alertBloc;
  int noFiles;
  List<html.File> files;
  AnimateEntranceBloc animateBloc;
  int selectedConfigIndex;

  @override
  void initState() {
    super.initState();
    // ignore: close_sinks
    noFiles = 0;
    authBloc = context.bloc<AuthBloc>();
    navBloc = context.bloc<NavBloc>();
    dataBloc = context.bloc<DataBloc>();
    animateBloc = context.bloc<AnimateEntranceBloc>();
    alertBloc = context.bloc<AlertBloc>();
    //launching entrence animation
    animateBloc.add(EnteringPage());
    _uploadSlideController =
        AnimationController(duration: Duration(milliseconds: 800), vsync: this);
    _uploadFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _uploadSlideController, curve: Curves.easeOut));
    _uploadSlide = Tween<Offset>(begin: const Offset(0.0, 1), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _uploadSlideController, curve: Curves.easeOut));
    Timer(Duration(milliseconds: 200), () {
      _uploadSlideController.forward();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _uploadSlideController.dispose();
  }

  void _sendFiles() {
    //here we send the uploaded files to the server
    //and navigate away to ...(check now the processing steps)
    if (noFiles > 0 && files.length > 0) {
      dataBloc.add(DoFileUpload(files, authBloc.user.id));
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Choose at leat one file before proceeding',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ));
    }
  }

  Future<void> _uploadFiles() async {
    //here we upload the files based on the file type config in the current
    //selected configuration
    var filesW;
    String extension = dataBloc.currentConfig.fileTypeAndSizeInMB['type'];
    filesW = await FilePicker.getMultiFile(
        type: FileType.custom, allowedExtensions: ['$extension']);
    if (filesW.length > 0) {
      for (html.File file in filesW) {
        print(file.name);
        print("file path: ${file.relativePath}");
        if (!file.name.endsWith(extension)) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(
                'Please select files with the extension of $extension',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.black,
          ));
          return;
        }
      }
      setState(() {
        print('file upload successfull\n .$extension');
        noFiles = filesW.length;
        files = filesW;
      });
      //FilePicker.clearTemporaryFiles();
      //send files to server
    }
  }

  @override
  Widget build(BuildContext context) {
    print('in web file upload page');
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
                    "Choose some file(s) to upload...",
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
                            position: _uploadSlide,
                            child: FadeTransition(
                              opacity: _uploadFadeIn,
                              child: Container(
                                width: appB.width * 0.5,
                                height: 40.0,
                                child: RaisedButton(
                                  onPressed: _uploadFiles,
                                  color: Colors.black,
                                  textColor: Colors.white,
                                  child: Text(
                                    "Select files",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 40.0),
                          ButtonBar(
                            alignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: MediaQuery.of(context).orientation ==
                                        Orientation.portrait
                                    ? appB.width
                                    : appB.width * 0.4,
                                height: 40.0,
                                child: RaisedButton(
                                  onPressed: () {
                                    //return to config page
                                    Timer(Duration(milliseconds: 100), () {
                                      animateBloc.add(LeavingPage());
                                      Timer(Duration(milliseconds: 500), () {
                                        navBloc.add(GoConfig());
                                      });
                                    });
                                  },
                                  color: Colors.grey[300],
                                  textColor: Assets.ubaRedColor,
                                  child: Text(
                                    "< previous",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                ),
                              ),
                              if (MediaQuery.of(context).orientation ==
                                  Orientation.portrait)
                                SizedBox(height: 10.0),
                              BlocListener<DataBloc, DataState>(
                                listener: (context, state) {
                                  if (state is FileUploaded && !state.errors) {
                                    alertBloc.add(CloseAlert());
                                    Timer(Duration(milliseconds: 100), () {
                                      Scaffold.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                            '${files.length} files processed for ${dataBloc.currentConfig.configName} configuration in ${state.processingTime} ',
                                            style: const TextStyle(
                                                color: Colors.white)),
                                        backgroundColor: Colors.black,
                                      ));
                                      Timer(Duration(milliseconds: 100), () {
                                        animateBloc.add(LeavingPage());
                                        Timer(Duration(milliseconds: 500), () {
                                          navBloc.add(GoResult());
                                          print("navigating to next step");
                                        });
                                      });
                                    });
                                  } else if (state is FileUploaded &&
                                      state.errors) {
                                    Timer(Duration(milliseconds: 100), () {
                                      Scaffold.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(state.message,
                                            style: const TextStyle(
                                                color: Colors.white)),
                                        backgroundColor: Colors.red,
                                      ));
                                    });
                                  }
                                },
                                child: BlocBuilder<DataBloc, DataState>(
                                  builder: (context, state) {
                                    if (state is FileUploading) {
                                      Timer(Duration(milliseconds: 100), () {
                                        alertBloc.add(ShowAlert(
                                          whatToShow: Container(
                                            height: 200,
                                            width: 200,
                                            color: Colors.white,
                                            padding: EdgeInsets.fromLTRB(
                                                24.0, 0.0, 24.0, 24.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Center(
                                                  child: SpinKitRing(
                                                      color: Assets.ubaRedColor,
                                                      size: 80.0),
                                                ),
                                                SizedBox(height: 10.0),
                                                Text(
                                                  "Please wait while your file(s) are being processed...",
                                                  textAlign: TextAlign.center,
                                                )
                                              ],
                                            ),
                                          ),
                                          isDoc: false,
                                          title: '',
                                          actions: [],
                                        ));
                                      });
                                    } else if (state is FileUploaded &&
                                        !state.errors) {}
                                    return Container(
                                      width:
                                          MediaQuery.of(context).orientation ==
                                                  Orientation.portrait
                                              ? appB.width
                                              : appB.width * 0.4,
                                      height: 40.0,
                                      child: RaisedButton(
                                        onPressed: state is FileUploading
                                            ? () {}
                                            : _sendFiles,
                                        color: Assets.ubaRedColor,
                                        hoverColor: Colors.black,
                                        disabledColor: Colors.redAccent,
                                        disabledTextColor: Colors.black,
                                        textColor: Colors.white,
                                        child: Text(
                                          state is FileUploading
                                              ? "Please wait"
                                              : "Start process",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.0),
                          Text(
                            noFiles < 1
                                ? "Only files with the extension ${dataBloc.currentConfig.fileTypeAndSizeInMB['type']} are supported"
                                : "$noFiles selected ,if done selecting you can proceed with the processing",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
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
