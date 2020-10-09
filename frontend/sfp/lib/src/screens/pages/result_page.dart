import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/countdown_timer.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pdf/pdf.dart' as pdfDart;
import 'package:pdf/widgets.dart' as pw;
import 'package:sfp/assets.dart';
import 'package:sfp/src/blocs/blocs.dart';
import 'package:sfp/src/models/models.dart';
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
  AuthBloc authBloc;
  NavBloc navBloc;
  FToast ftoast;
  DocBloc docBloc;
  int currentPage, totalPages;
  @override
  void initState() {
    super.initState();
    dataBloc = context.bloc<DataBloc>();
    animateBloc = context.bloc<AnimateEntranceBloc>();
    alertBloc = context.bloc<AlertBloc>();
    authBloc = context.bloc<AuthBloc>();
    navBloc = context.bloc<NavBloc>();
    docBloc = context.bloc<DocBloc>();
    currentPage = 1;
    totalPages = 0;
    ftoast = FToast();
    ftoast.init(context);
    //launching entrence animation
    animateBloc.add(EnteringPage());
    docBloc.add(ResetDoc());
  }

  void _downloadFiles() {
    //dispatch and generate the file on the servers
    dataBloc.add(
        DownloadFiles(authBloc.user.id, dataBloc.currentConfig.configName));
  }

  List<pw.Widget> _buildPdf(
      ProcessedFileModel file, String which, String configName) {
    pw.Widget retour = pw.Container();
    print('building th pdf for $which');
    switch (configName) {
      case "CANAL":
        switch (which) {
          case "original":
            int i = 0;
            List<String> headerList, headerListInitial;
            headerList = file.inFile[i]['ligne'].keys.toList();
            headerListInitial = file.inFile[i]['ligne'].keys.toList();
            //get maximum number of keys in the list of maps
            while (i < file.inFile.length - 1) {
              if (headerList.length <
                  file.inFile[i]['ligne'].keys.toList().length) {
                headerList = file.inFile[i]['ligne'].keys.toList();
                headerListInitial = file.inFile[i]['ligne'].keys.toList();
              }
              i++;
            }
            for (int i = 0; i < headerList.length; i++) {
              headerList[i] = headerList[i].replaceAll(new RegExp("\\d"), "");
              headerList[i] = headerList[i].replaceAll("~", "");
            }
            print('content of headerList is $headerList');
            List<pw.TableRow> tableLignes = [];
            //headers
            tableLignes.add(pw.TableRow(
              children: List.generate(headerList.length, (index) {
                print(headerList[index]);
                return pw.Container(
                  padding: const pw.EdgeInsets.all(2.0),
                  child: pw.Text(headerList[index],
                      textAlign: pw.TextAlign.center),
                );
              }),
            ));
            //Content
            tableLignes.addAll(List.generate(file.inFile.length, (index) {
              return pw.TableRow(
                children: List.generate(headerList.length, (i) {
                  //match with the appropriate header
                  if (file.inFile[index]['ligne'].keys.toList().length ==
                      headerListInitial.length) {
                    //if the content match the same length
                    //print(
                    //  "in map currently ${file.inFile[index]['ligne'].keys.toList()[i]} and in cell is ${headerListInitial[i]}");
                    if (file.inFile[index]['ligne'].keys.toList()[i] ==
                        headerListInitial[i]) {
                      //print("indeed they match");
                      return pw.Container(
                        padding: const pw.EdgeInsets.all(2.0),
                        child: pw.Text(
                            file.inFile[index]['ligne'][headerListInitial[i]],
                            textAlign: pw.TextAlign.center),
                      );
                    }
                  } else {
                    //here we either have to deal with the first CANAL+ line or the lastone

                    if (index == 0) {
                      String element =
                          i < file.inFile[index]['ligne'].keys.toList().length
                              ? file.inFile[index]['ligne'].keys.toList()[i]
                              : file.inFile[index]['ligne'].keys.toList().last;
                      print("the current element is $element");
                      // the indexes added to the keys are not starting from 0
                      if (element.contains("${i + 1}")) {
                        print(
                            'element is $element and contains the id $i and value is ${file.inFile[index]['ligne'][headerListInitial[i]]}');
                        return pw.Container(
                          padding: const pw.EdgeInsets.all(2.0),
                          child: pw.Text(
                              file.inFile[index]['ligne']
                                      [headerListInitial[i]] ??
                                  "",
                              textAlign: pw.TextAlign.center),
                        );
                      } else {
                        print(
                            "this index $i doesnt exist in keys so we try checking if the number set as index in the element match the value of the index+1");
                        int indexInEl = int.parse(
                            element.replaceAll(RegExp(r'[^0-9]'), ''));
                        print("the element index in json is $indexInEl");
                        if (/*element.contains('$indexInEl')*/ headerListInitial[
                                i] ==
                            element) {
                          print(
                              "yes element is $element index is $index and i is $i");
                          return pw.Container(
                            padding: const pw.EdgeInsets.all(2.0),
                            child: pw.Text(
                                file.fileLines[index]['ligne'][element] ?? "",
                                textAlign: pw.TextAlign.center),
                          );
                        }
                      }
                    } else if (index == file.inFile.length - 1 &&
                        i < file.inFile[index]['ligne'].keys.toList().length) {
                      //here we take care of the last line of the canal + file
                      print("last element ");
                      String lastElement =
                          file.inFile[index]['ligne'].keys.toList()[i];
                      print("last element $lastElement");
                      if (lastElement == "LASTLINE") {
                        var lastSplit = file.inFile[index]['ligne'][lastElement]
                            .split(RegExp("\\s+"));
                        print(lastSplit);
                        //we arbitrarily place the last line into random columns
                        if (i == 0) {
                          return pw.Container(
                            padding: const pw.EdgeInsets.all(2.0),
                            child: pw.Text(
                                '${lastSplit[0]}\t\t\t${lastSplit[1]}\t\t\t${lastSplit[2]}',
                                textAlign: pw.TextAlign.center),
                          );
                        } else {
                          return pw.Text("");
                        }
                      } else {
                        return pw.Text("");
                      }
                    }
                    return pw.Text("");
                  }
                  //return pw.Text("canal");
                }),
              );
              //return pw.TableRow();
            }));
            retour = pw.Table(
              border: pw.TableBorder(
                  top: true, left: true, right: true, bottom: true),
              children: tableLignes,
            );
            break;
          case "generated":
            int i = 0;
            List<String> headerList, headerListInitial;
            headerList = file.fileLines[i]['ligne'].keys.toList();
            headerListInitial = file.fileLines[i]['ligne'].keys.toList();
            //get maximum number of keys in the list of maps
            while (i < file.fileLines.length - 1) {
              if (headerList.length <
                  file.fileLines[i]['ligne'].keys.toList().length) {
                headerList = file.fileLines[i]['ligne'].keys.toList();
                headerListInitial = file.fileLines[i]['ligne'].keys.toList();
              }
              i++;
            }
            //for the generated file we should remove some unecessary columns
            //but those properties removed will be used to display and emphasize
            //the status of the processing
            /*headerList.remove("process_done~18");
            headerListInitial.remove("process_done~18");
            headerList.remove("process_done~18");
            headerListInitial.remove("process_done~18");
            headerList.remove("SCHM_DESC~17");
            headerListInitial.remove("SCHM_DESC~17");
            headerList.remove("SCHM_CODE~16");
            headerListInitial.remove("SCHM_CODE~16");
            headerList.remove("FREEZECODE~13");
            headerListInitial.remove("FREEZECODE~13");
            headerList.remove("FREEZEREASON~14");
            headerListInitial.remove("FREEZEREASON~14");
            headerList.remove("ACCOUNTCLOSEDATE~15");
            headerListInitial.remove("ACCOUNTCLOSEDATE~15");
            headerList.remove("LINENO~10");
            headerListInitial.remove("LINENO~10");*/

            for (int i = 0; i < headerList.length; i++) {
              headerList[i] = headerList[i].replaceAll(new RegExp("\\d"), "");
              headerList[i] = headerList[i].replaceAll("~", "");
            }

            print('content of headerList is $headerList');
            List<pw.TableRow> tableLignes = [];
            //headers
            tableLignes.add(pw.TableRow(
              children: List.generate(headerList.length, (index) {
                print(headerList[index]);
                return pw.Container(
                  padding: const pw.EdgeInsets.all(2.0),
                  child: pw.Text(headerList[index],
                      textAlign: pw.TextAlign.center),
                );
              }),
            ));
            //Content
            tableLignes.addAll(List.generate(file.fileLines.length, (index) {
              return pw.TableRow(
                children: List.generate(headerList.length, (i) {
                  //here we either have to deal with the first CANAL+ line or the lastone
                  if (index == 0) {
                    String element =
                        i < file.fileLines[index]['ligne'].keys.toList().length
                            ? file.fileLines[index]['ligne'].keys
                                .toList()[i]
                                .toString()
                            : file.fileLines[index]['ligne'].keys
                                .toList()
                                .last
                                .toString();
                    print("the current element is $element");
                    // the indexes added to the keys are not starting from 0
                    if (element.contains("${i + 1}")) {
                      print(
                          'element is $element and contains the id $i and value is ${file.fileLines[index]['ligne'][headerListInitial[i]]}');
                      return pw.Container(
                        padding: const pw.EdgeInsets.all(2.0),
                        child: pw.Text(
                            file.fileLines[index]['ligne']
                                    [headerListInitial[i]] ??
                                "",
                            textAlign: pw.TextAlign.center),
                      );
                    } else {
                      print(
                          "this index $i doesnt exist in keys so we try checking if the number set as index in the element match the value of the index+1");
                      int indexInEl =
                          int.parse(element.replaceAll(RegExp(r'[^0-9]'), ''));
                      print("the element index in json is $indexInEl");
                      if (/*element.contains('$indexInEl')*/ headerListInitial[
                              i] ==
                          element) {
                        print(
                            "yes element is $element index is $index and i is $i");
                        return pw.Container(
                          padding: const pw.EdgeInsets.all(2.0),
                          child: pw.Text(
                              file.fileLines[index]['ligne'][element] ?? "",
                              textAlign: pw.TextAlign.center),
                        );
                      }
                    }
                  } else if (index == file.fileLines.length - 1 &&
                      i < file.fileLines[index]['ligne'].keys.toList().length) {
                    //here we take care of the last line of the canal + file
                    print("last element ");
                    String lastElement =
                        file.fileLines[index]['ligne'].keys.toList()[i];
                    print("last element $lastElement");
                    if (lastElement == "LASTLINE") {
                      var lastSplit = file.fileLines[index]['ligne']
                              [lastElement]
                          .split(RegExp("\\s+"));
                      print(lastSplit);
                      //we arbitrarily place the last line into random columns
                      if (i == 0) {
                        return pw.Container(
                          padding: const pw.EdgeInsets.all(2.0),
                          child: pw.Text(
                              '${lastSplit[0]}\t\t\t${lastSplit[1]}\t\t\t${lastSplit[2]}',
                              textAlign: pw.TextAlign.center),
                        );
                      } else {
                        return pw.Text("");
                      }
                    } else {
                      return pw.Text("");
                    }
                  } else {
                    //here is for the inner content
                    String element =
                        i < file.fileLines[index]['ligne'].keys.toList().length
                            ? file.fileLines[index]['ligne'].keys
                                .toList()[i]
                                .toString()
                            : file.fileLines[index]['ligne'].keys
                                .toList()
                                .last
                                .toString();
                    print("the current element is $element generated files");

                    // print("current line is ${file.fileLines[index]['ligne']}");
                    String theText = '';
                    if (headerListInitial[i] == element) {
                      print("yes they are equal");
                      theText =
                          file.fileLines[index]['ligne'][element].toString() ??
                              "";
                      print("element is $theText");
                    }
                    return pw.Container(
                        color: file.fileLines[index]["ligne"]
                                        ["status_code~19"] ==
                                    "00" &&
                                file.fileLines[index]["ligne"]
                                    ["process_done~18"]
                            ? pdfDart.PdfColor(0, 1, 0)
                            : file.fileLines[index]["ligne"]
                                        ["status_code~19"] ==
                                    "04"
                                /*&&
                            file.fileLines[index]["ligne"]["process_done~18"]*/
                                ? pdfDart.PdfColor(0, 0, 0)
                                : file.fileLines[index]["ligne"]
                                            ["status_code~19"] ==
                                        "06"
                                    ? pdfDart.PdfColor(1, 0, 0)
                                    : pdfDart.PdfColor(1, 1, 1, 0),
                        padding: const pw.EdgeInsets.all(2.0),
                        child: pw.Text(
                          theText,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                              color: file.fileLines[index]["ligne"]
                                          ["status_code~19"] ==
                                      "04"
                                  ? pdfDart.PdfColor(1, 1, 1)
                                  : pdfDart.PdfColor(0, 0, 0)),
                        ));
                  }
                  return pw.Text("");
                }),
              );
              //return pw.TableRow();
            }));
            retour = pw.Table(
              tableWidth: pw.TableWidth.max,
              border: pw.TableBorder(
                  top: true, left: true, right: true, bottom: true),
              children: tableLignes,
            );
            break;
          default:
            retour = pw.Center(child: pw.Text("Nothing to display"));
            break;
        }
        break;
      case "SAGE":
        switch (which) {
          case "original":
            int i = 0;
            List<String> headerList, headerListInitial;
            headerList = file.inFile[i]['ligne'].keys.toList();
            headerListInitial = file.inFile[i]['ligne'].keys.toList();
            //get maximum number of keys in the list of maps
            while (i < file.inFile.length - 1) {
              if (headerList.length <
                  file.inFile[i]['ligne'].keys.toList().length) {
                headerList = file.inFile[i]['ligne'].keys.toList();
                headerListInitial = file.inFile[i]['ligne'].keys.toList();
              }
              i++;
            }
            for (int i = 0; i < headerList.length; i++) {
              headerList[i] = headerList[i].replaceAll(new RegExp("\\d"), "");
              headerList[i] = headerList[i].replaceAll("~", "");
            }
            // if (headerList.remove("LINENO") &&
            //     headerListInitial.remove("LINENO~0")) {
            //   print("LINENO removed");
            // }
            print('content of headerList in sage is $headerList');
            List<pw.TableRow> tableLignes = [];
            //headers
            tableLignes.add(pw.TableRow(
              children: List.generate(headerList.length, (index) {
                print(headerList[index]);
                return pw.Container(
                  padding: const pw.EdgeInsets.all(2.0),
                  child: pw.Text(headerList[index],
                      textAlign: pw.TextAlign.center),
                );
              }),
            ));
            //Content
            tableLignes.addAll(List.generate(file.inFile.length, (index) {
              return pw.TableRow(
                children: List.generate(headerList.length, (i) {
                  //match with the appropriate header
                  if (file.inFile[index]['ligne'].keys.toList().length ==
                      headerListInitial.length) {
                    //if the content match the same length
                    //print(
                    //  "in map currently ${file.inFile[index]['ligne'].keys.toList()[i]} and in cell is ${headerListInitial[i]}");
                    if (file.inFile[index]['ligne'].keys.toList()[i] ==
                        headerListInitial[i]) {
                      //print("indeed they match");
                      return pw.Container(
                        padding: const pw.EdgeInsets.all(2.0),
                        child: pw.Text(
                            file.inFile[index]['ligne'][headerListInitial[i]],
                            textAlign: pw.TextAlign.center),
                      );
                    }
                  } else {
                    //here we either have to deal with the first CANAL+ line or the lastone

                    if (index == 0) {
                      String element =
                          i < file.inFile[index]['ligne'].keys.toList().length
                              ? file.inFile[index]['ligne'].keys.toList()[i]
                              : file.inFile[index]['ligne'].keys.toList().last;
                      print("the current element is $element");
                      // the indexes added to the keys are not starting from 0
                      if (element.contains("${i + 1}")) {
                        print(
                            'element is $element and contains the id $i and value is ${file.inFile[index]['ligne'][headerListInitial[i]]}');
                        return pw.Container(
                          padding: const pw.EdgeInsets.all(2.0),
                          child: pw.Text(
                              file.inFile[index]['ligne']
                                      [headerListInitial[i]] ??
                                  "",
                              textAlign: pw.TextAlign.center),
                        );
                      } else {
                        print(
                            "this index $i doesnt exist in keys so we try checking if the number set as index in the element match the value of the index+1");
                        int indexInEl = int.parse(
                            element.replaceAll(RegExp(r'[^0-9]'), ''));
                        print("the element index in json is $indexInEl");
                        if (/*element.contains('$indexInEl')*/ headerListInitial[
                                i] ==
                            element) {
                          print(
                              "yes element is $element index is $index and i is $i");
                          return pw.Container(
                            padding: const pw.EdgeInsets.all(2.0),
                            child: pw.Text(
                                file.inFile[index]['ligne'][element] ?? "",
                                textAlign: pw.TextAlign.center),
                          );
                        }
                      }
                    } else if (index == file.inFile.length - 1 &&
                        i < file.inFile[index]['ligne'].keys.toList().length) {
                      //here we take care of the last line of the canal + file
                      print("last element ");
                      String lastElement =
                          file.inFile[index]['ligne'].keys.toList()[i];
                      print("last element $lastElement");
                      if (lastElement == "LASTLINE") {
                        var lastSplit = file.inFile[index]['ligne'][lastElement]
                            .split(RegExp("\\s+"));
                        print(lastSplit);
                        //we arbitrarily place the last line into random columns
                        if (i == 0) {
                          return pw.Container(
                            padding: const pw.EdgeInsets.all(2.0),
                            child: pw.Text(
                                '${lastSplit[0]}\t\t\t${lastSplit[1]}\t\t\t${lastSplit[2]}',
                                textAlign: pw.TextAlign.center),
                          );
                        } else {
                          return pw.Text("");
                        }
                      } else {
                        return pw.Text("");
                      }
                    }
                    return pw.Text("");
                  }
                  //return pw.Text("canal");
                }),
              );
              //return pw.TableRow();
            }));
            retour = pw.Table(
              border: pw.TableBorder(
                  top: true, left: true, right: true, bottom: true),
              children: tableLignes,
            );
            break;
          case "generated":
            int i = 0;
            List<String> headerList, headerListInitial;
            headerList = file.fileLines[i]['ligne'].keys.toList();
            headerListInitial = file.fileLines[i]['ligne'].keys.toList();
            //get maximum number of keys in the list of maps
            while (i < file.fileLines.length - 1) {
              if (headerList.length <
                  file.fileLines[i]['ligne'].keys.toList().length) {
                headerList = file.fileLines[i]['ligne'].keys.toList();
                headerListInitial = file.fileLines[i]['ligne'].keys.toList();
              }
              i++;
            }
            for (int i = 0; i < headerList.length; i++) {
              headerList[i] = headerList[i].replaceAll(new RegExp("\\d"), "");
              headerList[i] = headerList[i].replaceAll("~", "");
            }
            // if (headerList.remove("LINENO") &&
            //     headerListInitial.remove("LINENO~0")) {
            //   print("LINENO removed");
            // }
            print('content of headerList in sage is $headerList');
            List<pw.TableRow> tableLignes = [];
            //headers
            tableLignes.add(pw.TableRow(
              children: List.generate(headerList.length, (index) {
                print(headerList[index]);
                return pw.Container(
                  padding: const pw.EdgeInsets.all(2.0),
                  child: pw.Text(headerList[index],
                      textAlign: pw.TextAlign.center),
                );
              }),
            ));
            //Content
            tableLignes.addAll(List.generate(file.fileLines.length, (index) {
              return pw.TableRow(
                children: List.generate(headerList.length, (i) {
                  //match with the appropriate header
                  if (file.fileLines[index]['ligne'].keys.toList().length ==
                      headerListInitial.length) {
                    //if the content match the same length
                    //print(
                    //  "in map currently ${file.inFile[index]['ligne'].keys.toList()[i]} and in cell is ${headerListInitial[i]}");
                    if (file.fileLines[index]['ligne'].keys.toList()[i] ==
                        headerListInitial[i]) {
                      //print("indeed they match");
                      return pw.Container(
                        padding: const pw.EdgeInsets.all(2.0),
                        child: pw.Text(
                            file.fileLines[index]['ligne']
                                [headerListInitial[i]],
                            textAlign: pw.TextAlign.center),
                      );
                    }
                  } else {
                    return pw.Text("");
                  }
                  //return pw.Text("canal");
                }),
              );
              //return pw.TableRow();
            }));
            retour = pw.Table(
              border: pw.TableBorder(
                  top: true, left: true, right: true, bottom: true),
              children: tableLignes,
            );
            break;
          default:
            retour = pw.Center(child: pw.Text("Nothing to display"));
            break;
        }
        break;
    }

    return [retour];
  }

  void _showToast(String message) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Color.fromRGBO(237, 90, 90, 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info),
          SizedBox(
            width: 12.0,
          ),
          Text(message, style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
    if (kIsWeb) {
      ftoast.showToast(
        child: toast,
        toastDuration: Duration(seconds: 4),
        gravity: ToastGravity.BOTTOM,
      );
    } else {
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 2,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Color.fromRGBO(237, 90, 90, 0.5),
          textColor: Colors.black,
          fontSize: 12.0);
    }
  }

  List<Widget> generateFileWidgets(pw.Document pdf, Size appB) {
    List<Widget> l = List.generate(dataBloc.processedFiles.length, (i) {
      // File inFile = MemoryFileSystem().file('original.pdf')
      //   ..writeAsBytesSync(utf8.encode(
      //       dataBloc.processedFiles[i].inFile['data']));
      // print(inFile.readAsBytesSync());
      // final inFilePDF = PdfImage.file(pdf.document,
      //     bytes: inFile.readAsBytesSync());
      int windex = i + 1;
      return Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200])),
        ),
        child: Column(
          children: [
            if (dataBloc.processedFiles[i].processingStatus)
              Text(
                "The file is done processing.",
                textAlign: TextAlign.center,
              ),
            if (dataBloc.processedFiles[i].lastExecution.year != 1970 &&
                !dataBloc.processedFiles[i].processingStatus)
              Responsive.isMobile(context)
                  ? BlocBuilder<DataBloc, DataState>(
                      builder: (context, state) {
                        if (state is FileFetching) {
                          return Container(
                            child: Center(
                              child: Column(
                                children: [
                                  SpinKitRing(
                                      color: Assets.ubaRedColor, size: 60.0),
                                  SizedBox(height: 10.0),
                                  Text("Fetching new execution times")
                                ],
                              ),
                            ),
                          );
                        } else if (state is FileLoaded) {
                          return Container(
                              child: Column(
                            children: [
                              Text(
                                "Previous execution Time: ${DateTime(dataBloc.processedFiles[i].lastExecution.year, dataBloc.processedFiles[i].lastExecution.month, dataBloc.processedFiles[i].lastExecution.day, dataBloc.processedFiles[i].lastExecution.hour, dataBloc.processedFiles[i].lastExecution.minute)}"
                                    .replaceAll(":00.000", ""),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              Container(
                                child: Column(
                                  children: [
                                    Text(
                                      "Time left before next execution:",
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 10.0),
                                    CountdownTimer(
                                      endTime: dataBloc
                                              .processedFiles[i]
                                              .nextExecution
                                              .millisecondsSinceEpoch +
                                          3000,
                                      textStyle: const TextStyle(
                                          fontSize: 30.0,
                                          fontWeight: FontWeight.bold),
                                      onEnd: () {
                                        print(
                                            'now should wait for 3 seconds before requesting update from server');
                                        dataBloc.add(PreparingFileFetching());
                                        Timer(Duration(milliseconds: 100), () {
                                          dataBloc.add(FetchFilesForConfig(
                                              dataBloc.currentConfig.configName,
                                              authBloc.user.id));
                                          Timer(Duration(milliseconds: 2900),
                                              () {
                                            _showToast(
                                                "Running the background process now.Please wait...");
                                          });
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "Next execution time: ${DateTime(dataBloc.processedFiles[i].nextExecution.year, dataBloc.processedFiles[i].nextExecution.month, dataBloc.processedFiles[i].nextExecution.day, dataBloc.processedFiles[i].nextExecution.hour, dataBloc.processedFiles[i].nextExecution.minute)}"
                                    .replaceAll(":00.000", ""),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ));
                        }
                        return Container();
                      },
                    )
                  : BlocBuilder<DataBloc, DataState>(builder: (context, state) {
                      if (state is FileFetching) {
                        return Container(
                          child: Center(
                            child: Column(
                              children: [
                                SpinKitRing(
                                    color: Assets.ubaRedColor, size: 60.0),
                                SizedBox(height: 10.0),
                                Text("Fetching new execution times")
                              ],
                            ),
                          ),
                        );
                      } else if (state is FileLoaded) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Previous execution Time: ${DateTime(dataBloc.processedFiles[i].lastExecution.year, dataBloc.processedFiles[i].lastExecution.month, dataBloc.processedFiles[i].lastExecution.day, dataBloc.processedFiles[i].lastExecution.hour, dataBloc.processedFiles[i].lastExecution.minute)}"
                                  .replaceAll(":00.000", ""),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              child: Column(
                                children: [
                                  Text("Time left before next execution:"),
                                  SizedBox(height: 10.0),
                                  CountdownTimer(
                                    endTime: dataBloc
                                            .processedFiles[i]
                                            .nextExecution
                                            .millisecondsSinceEpoch +
                                        3000,
                                    textStyle: const TextStyle(
                                        fontSize: 30.0,
                                        fontWeight: FontWeight.bold),
                                    onEnd: () {
                                      print(
                                          'now should wait for 3 seconds before requesting update from server');
                                      dataBloc.add(PreparingFileFetching());
                                      Timer(Duration(milliseconds: 100), () {
                                        dataBloc.add(FetchFilesForConfig(
                                            dataBloc.currentConfig.configName,
                                            authBloc.user.id));
                                        Timer(Duration(milliseconds: 2900), () {
                                          _showToast(
                                              "Running the background process now.Please wait...");
                                        });
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Text(
                                "Next execution time: ${DateTime(dataBloc.processedFiles[i].nextExecution.year, dataBloc.processedFiles[i].nextExecution.month, dataBloc.processedFiles[i].nextExecution.day, dataBloc.processedFiles[i].nextExecution.hour, dataBloc.processedFiles[i].nextExecution.minute)}"
                                    .replaceAll(":00.000", ""),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        );
                      }
                      return Container();
                    }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  height: Responsive.isMobile(context) ? 150 : 200,
                  width: Responsive.isMobile(context) ? 150 : 200,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
                  child: Tooltip(
                    message: "click to see the initial file you uploaded",
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      onPressed: () {
                        print("clear document");
                        pdf = pw.Document();
                        pdf.addPage(pw.MultiPage(
                            pageFormat: pdfDart.PdfPageFormat(
                                100 * pdfDart.PdfPageFormat.cm,
                                dataBloc.currentConfig.configName == "CANAL"
                                    ? 25 * pdfDart.PdfPageFormat.cm
                                    : 50 * pdfDart.PdfPageFormat.cm,
                                marginAll: 0.5 * pdfDart.PdfPageFormat.cm),
                            build: (pw.Context context) {
                              return _buildPdf(
                                  dataBloc.processedFiles[i],
                                  "original",
                                  dataBloc.currentConfig.configName);
                            }));
                        var doc = pdf.save();

                        alertBloc.add(ShowAlert(
                            whatToShow: null,
                            isDoc: true,
                            doc: doc,
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  alertBloc.add(CloseAlert());
                                },
                                child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("CLOSE")),
                              )
                            ],
                            title: 'Original file $windex'));
                        _showToast(kIsWeb
                            ? "Use the mouse wheel to zoom in or out on the area of interest"
                            : "Pinch with your fingers to zoom in or out of the document");
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            color: Assets.ubaRedColor,
                            size: Responsive.isMobile(context) ? 50 : 80,
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            "Initial file",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize:
                                    Responsive.isMobile(context) ? 14.0 : 20.0,
                                fontWeight: FontWeight.w600),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  height: Responsive.isMobile(context) ? 150 : 200,
                  width: Responsive.isMobile(context) ? 150 : 200,
                  child: Tooltip(
                    message:
                        "click to see the new file generated after processing ",
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      onPressed: () {
                        pdf = pw.Document();
                        pdf.addPage(pw.MultiPage(
                            pageFormat: pdfDart.PdfPageFormat(
                                100 * pdfDart.PdfPageFormat.cm,
                                dataBloc.currentConfig.configName == "CANAL"
                                    ? 25 * pdfDart.PdfPageFormat.cm
                                    : 50 * pdfDart.PdfPageFormat.cm,
                                marginAll: 0.5 * pdfDart.PdfPageFormat.cm),
                            build: (pw.Context context) {
                              return _buildPdf(
                                  dataBloc.processedFiles[i],
                                  "generated",
                                  dataBloc.currentConfig.configName);
                            }));
                        var doc = pdf.save();

                        alertBloc.add(ShowAlert(
                            whatToShow: null,
                            isDoc: true,
                            doc: doc,
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  alertBloc.add(CloseAlert());
                                },
                                child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("CLOSE")),
                              )
                            ],
                            title: 'Original file $windex'));
                        _showToast(kIsWeb
                            ? "Use the mouse wheel to zoom in or out on the area of interest"
                            : "Pinch with your fingers to zoom in or out of the document");
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.description_outlined,
                              color: Assets.ubaRedColor,
                              size: Responsive.isMobile(context) ? 50 : 80),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            "Generated file",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize:
                                    Responsive.isMobile(context) ? 14.0 : 20.0,
                                fontWeight: FontWeight.w600),
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
                Text("File $windex"),
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
                          onPressed: () => Navigator.of(context).pop(),
                          child: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("CANCEL",
                                  style:
                                      const TextStyle(color: Colors.black)))),
                      FlatButton(
                          onPressed: () {
                            print("i index $i");
                            Navigator.of(context).pop();
                            dataBloc.add(DiscardFiles(
                                files: [dataBloc.processedFiles[--windex]]));
                          },
                          child: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("DISCARD IT")))
                    ],
                  )),
                )
              ],
            ),
          ],
        ),
      );
    });
    l.addAll([
      SizedBox(height: 20.0),
      if (dataBloc.currentValidation != null &&
          dataBloc.currentValidation.initiatorId == authBloc.user.id &&
          dataBloc.currentConfig.functionnalityTypes.contains("VALIDATIONS"))
        ValidatingProcess(
          whoViewThis: "INITIATOR",
        ),
      if (dataBloc.currentValidation != null &&
          dataBloc.currentValidation.initiatorId != authBloc.user.id &&
          dataBloc.currentConfig.functionnalityTypes.contains("VALIDATIONS"))
        ValidatingProcess(
          whoViewThis: "VALIDATOR",
        ),
      Container(
        width:
            Responsive.isMobile(context) ? appB.width * 0.5 : appB.width * 0.15,
        height: 40.0,
        child: BlocBuilder<DataBloc, DataState>(
          builder: (context, state) {
            if (state is FilesDownloaded) {
              //trigger the download
              if (kIsWeb) {
                for (int i = 0; i < state.urlList.length; i++) {
                  final content = "kilo";
                  print("file url is ${state.urlList[i]}");
                  // final anchor = html.AnchorElement(
                  //     href:
                  //         "data:/application/octet-stream;charset=utf-16le;base64,$content")
                  //   ..setAttribute(
                  //       "download",
                  //       dataBloc.currentConfig.configName == "SAGE"
                  //           ? "JOURNAL ENTRIES ${++i}.xlsx"
                  //           : "")
                  //   ..click();
                }
              }
            }
            return dataBloc.currentValidation != null &&
                    dataBloc.currentValidation.initiatorId ==
                        authBloc.user.id &&
                    dataBloc.currentConfig.functionnalityTypes.contains(
                        "VALIDATIONS") //Initiator when validation started
                ? RaisedButton(
                    onPressed: dataBloc.validationProgress == 100
                        ? () => print("can send the file to destinataire")
                        : null,
                    color: Assets.ubaRedColor,
                    hoverColor: Colors.black,
                    textColor: Colors.white,
                    child: Text(
                      "Send File",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  )
                : dataBloc.currentValidation != null &&
                        dataBloc.currentValidation.initiatorId !=
                            authBloc.user.id &&
                        dataBloc.currentConfig.functionnalityTypes
                            .contains("VALIDATIONS") //Validators
                    ? Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RaisedButton(
                              onPressed: () {},
                              color: Assets.ubaRedColor,
                              hoverColor: Colors.black,
                              textColor: Colors.white,
                              child: Text(
                                "Reject",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                            ),
                            RaisedButton(
                              onPressed: () {},
                              color: Assets.ubaRedColor,
                              hoverColor: Colors.black,
                              textColor: Colors.white,
                              child: Text(
                                "Acknowledge",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                            ),
                          ],
                        ),
                      )
                    : dataBloc.currentValidation == null &&
                            dataBloc.currentConfig.functionnalityTypes.contains(
                                "VALIDATIONS") //Initiator when validation hasnt started yet
                        ? RaisedButton(
                            onPressed:
                                dataBloc.processedFiles.first.processingStatus
                                    ? _downloadFiles
                                    : null,
                            color: Assets.ubaRedColor,
                            hoverColor: Colors.black,
                            textColor: Colors.white,
                            child: Text(
                              "Submit for review",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          )
                        : RaisedButton(
                            onPressed:
                                dataBloc.processedFiles.first.processingStatus
                                    ? _downloadFiles
                                    : null,
                            color: Colors.black,
                            textColor: Colors.white,
                            child: Text(
                              "Download files",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          );
          },
        ),
      ),
    ]);
    return l;
  }

  @override
  Widget build(BuildContext context) {
    Size appB = Size(MediaQuery.of(context).size.width, 80.0);
    final pdf = pw.Document();
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
                  if (dataBloc.currentConfig.configName == "CANAL")
                    Container(
                      alignment: Alignment.topCenter,
                      margin: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                          "CANAL+ configuration has some scheduled operations that are planned to run",
                          textAlign: TextAlign.center),
                    ),
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
                        children: generateFileWidgets(pdf, appB),
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
