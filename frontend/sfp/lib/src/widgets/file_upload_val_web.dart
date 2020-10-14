import 'dart:async';

import 'package:file_picker/file_picker.dart'
    if (dart.library.html) 'package:file_picker_web/file_picker_web.dart';
import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfp/src/blocs/blocs.dart';
import 'package:sfp/utils.dart';
import 'package:universal_html/html.dart' as html;

class FileUploadValidatorWeb extends StatefulWidget {
  FileUploadValidatorWeb({Key key}) : super(key: key);

  @override
  FileUploadValidatorWebState createState() => FileUploadValidatorWebState();
}

class FileUploadValidatorWebState extends State<FileUploadValidatorWeb>
    with TickerProviderStateMixin {
  int noFiles;
  List<html.File> files;
  int selectedConfigIndex;
  DataBloc dataBloc;

  @override
  void initState() {
    super.initState();
    // ignore: close_sinks
    dataBloc = context.bloc<DataBloc>();
    noFiles = 0;
  }

  @override
  void dispose() {
    super.dispose();
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
        Utils.log(file.name);
        Utils.log("file path: ${file.relativePath}");
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
        Utils.log('file upload successfull\n .$extension');
        noFiles = filesW.length;
        files = filesW;
      });
      //FilePicker.clearTemporaryFiles();
      //send files to server
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            width: 300,
            padding: const EdgeInsets.all(10.0),
            child: RaisedButton(
              onPressed: _uploadFiles,
              color: Colors.black,
              textColor: Colors.white,
              child: Text(
                "select files",
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
          SizedBox(height: 20.0),
          Text(
            noFiles < 1
                ? "Only files with the extension ${dataBloc.currentConfig.fileTypeAndSizeInMB['type']} are supported"
                : "$noFiles selected",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
