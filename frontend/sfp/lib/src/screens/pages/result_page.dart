import 'dart:async';
import 'dart:typed_data';

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
import 'package:sfp/src/widgets/validation_steps.dart';
import 'package:sfp/src/widgets/widgets.dart';
import 'package:sfp/utils.dart';

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
  var firstTotalValue, secondTotalValue;
  List<Uint8List> docInitial, docGenerated;
  TextEditingController _rejectionController;
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
    _rejectionController = TextEditingController();
    ftoast = FToast();
    ftoast.init(context);
    alertBloc.add(CloseAlert());
    //if(dataBloc.processedFiles.isNotEmpty)
    dataBloc.add(GetValidationProcess(
        configName: dataBloc.currentConfigName,
        initiatorId: authBloc.user.role == "INITIATOR"
            ? authBloc.user.id
            : authBloc.user.role == "VALIDATOR" ||
                    authBloc.user.role == "CONTROLLER"
                ? authBloc.user.creatorId
                : authBloc.user.id));
    //launching entrence animation
    animateBloc.add(EnteringPage());
    docBloc.add(ResetDoc());
  }

  @override
  void dispose() {
    super.dispose();
    _rejectionController.dispose();
  }

  void _downloadFiles() {
    //dispatch and generate the file on the servers
    dataBloc.add(DownloadFiles(authBloc.user.id, dataBloc.currentConfigName));
  }

  // Future<void> _getDocuments() async {
  //   var initials = await compute(_buildDocument, "original");
  //   var generated = await compute(_buildDocument, "generated");
  //   setState(() {
  //     docInitial = initials;
  //     docGenerated = generated;
  //     _showToast("The files are ready to be reviewed");
  //   });
  // }

  List<Uint8List> _buildDocument(Map<String, dynamic> map) {
    List<Uint8List> docs = [];
    for (int i = 0; i < dataBloc.processedFiles.length; i++) {
      Utils.log("clear document");
      var pdf = pw.Document();
      pdf.addPage(pw.MultiPage(
          pageFormat: pdfDart.PdfPageFormat(
              100 * pdfDart.PdfPageFormat.cm,
              dataBloc.currentConfigName == "CANAL"
                  ? 25 * pdfDart.PdfPageFormat.cm
                  : 50 * pdfDart.PdfPageFormat.cm,
              marginAll: 0.5 * pdfDart.PdfPageFormat.cm),
          build: (pw.Context context) {
            return _buildPdf(dataBloc.processedFiles[i], map['which'],
                dataBloc.currentConfigName, map['dataBloc']);
          }));
      var doc = pdf.save();
      docs.add(doc);
    }
    return docs;
  }

  static List<pw.Widget> _buildPdf(ProcessedFileModel file, String which,
      String configName, DataBloc dataBloc) {
    pw.Widget retour = pw.Container();
    Utils.log('building th pdf for $which is dataBloc set ${dataBloc != null}');
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
            Utils.log('content of headerList is $headerList');
            List<pw.TableRow> tableLignes = [];
            //headers
            tableLignes.add(pw.TableRow(
              children: List.generate(headerList.length, (index) {
                Utils.log(headerList[index]);
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
                    //Utils.log(
                    //  "in map currently ${file.inFile[index]['ligne'].keys.toList()[i]} and in cell is ${headerListInitial[i]}");
                    if (file.inFile[index]['ligne'].keys.toList()[i] ==
                        headerListInitial[i]) {
                      //Utils.log("indeed they match");
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
                      Utils.log("the current element is $element");
                      // the indexes added to the keys are not starting from 0
                      if (element.contains("${i + 1}")) {
                        Utils.log(
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
                        Utils.log(
                            "this index $i doesnt exist in keys so we try checking if the number set as index in the element match the value of the index+1");
                        int indexInEl = int.parse(
                            element.replaceAll(RegExp(r'[^0-9]'), ''));
                        Utils.log("the element index in json is $indexInEl");
                        if (/*element.contains('$indexInEl')*/ headerListInitial[
                                i] ==
                            element) {
                          Utils.log(
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
                      Utils.log("last element ");
                      String lastElement =
                          file.inFile[index]['ligne'].keys.toList()[i];
                      Utils.log("last element $lastElement");
                      if (lastElement == "LASTLINE") {
                        var lastSplit = file.inFile[index]['ligne'][lastElement]
                            .split(RegExp("\\s+"));
                        Utils.log(lastSplit);
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

            Utils.log('content of headerList is $headerList');
            List<pw.TableRow> tableLignes = [];
            //headers
            tableLignes.add(pw.TableRow(
              children: List.generate(headerList.length, (index) {
                Utils.log(headerList[index]);
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
                    Utils.log("the current element is $element");
                    // the indexes added to the keys are not starting from 0
                    if (element.contains("${i + 1}")) {
                      Utils.log(
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
                      Utils.log(
                          "this index $i doesnt exist in keys so we try checking if the number set as index in the element match the value of the index+1");
                      int indexInEl =
                          int.parse(element.replaceAll(RegExp(r'[^0-9]'), ''));
                      Utils.log("the element index in json is $indexInEl");
                      if (/*element.contains('$indexInEl')*/ headerListInitial[
                              i] ==
                          element) {
                        Utils.log(
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
                    Utils.log("last element ");
                    String lastElement =
                        file.fileLines[index]['ligne'].keys.toList()[i];
                    Utils.log("last element $lastElement");
                    if (lastElement == "LASTLINE") {
                      var lastSplit = file.fileLines[index]['ligne']
                              [lastElement]
                          .split(RegExp("\\s+"));
                      Utils.log(lastSplit);
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
                    Utils.log(
                        "the current element is $element generated files");

                    // Utils.log("current line is ${file.fileLines[index]['ligne']}");
                    String theText = '';
                    if (headerListInitial[i] == element) {
                      Utils.log("yes they are equal");
                      theText =
                          file.fileLines[index]['ligne'][element].toString() ??
                              "";
                      Utils.log("element is $theText");
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
            //   Utils.log("LINENO removed");
            // }
            Utils.log('content of headerList in sage is $headerList');
            List<pw.TableRow> tableLignes = [];
            //headers
            tableLignes.add(pw.TableRow(
              children: List.generate(headerList.length, (index) {
                Utils.log(headerList[index]);
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
                    //Utils.log(
                    //  "in map currently ${file.inFile[index]['ligne'].keys.toList()[i]} and in cell is ${headerListInitial[i]}");
                    if (file.inFile[index]['ligne'].keys.toList()[i] ==
                        headerListInitial[i]) {
                      //Utils.log("indeed they match");
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
                      Utils.log("the current element is $element");
                      // the indexes added to the keys are not starting from 0
                      if (element.contains("${i + 1}")) {
                        Utils.log(
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
                        Utils.log(
                            "this index $i doesnt exist in keys so we try checking if the number set as index in the element match the value of the index+1");
                        int indexInEl = int.parse(
                            element.replaceAll(RegExp(r'[^0-9]'), ''));
                        Utils.log("the element index in json is $indexInEl");
                        if (/*element.contains('$indexInEl')*/ headerListInitial[
                                i] ==
                            element) {
                          Utils.log(
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
                      Utils.log("last element ");
                      String lastElement =
                          file.inFile[index]['ligne'].keys.toList()[i];
                      Utils.log("last element $lastElement");
                      if (lastElement == "LASTLINE") {
                        var lastSplit = file.inFile[index]['ligne'][lastElement]
                            .split(RegExp("\\s+"));
                        Utils.log(lastSplit);
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
            //   Utils.log("LINENO removed");
            // }
            Utils.log('content of headerList in sage is $headerList');
            List<pw.TableRow> tableLignes = [];
            //headers
            tableLignes.add(pw.TableRow(
              children: List.generate(headerList.length, (index) {
                Utils.log(headerList[index]);
                return pw.Container(
                  padding: const pw.EdgeInsets.all(2.0),
                  child: pw.Text(headerList[index],
                      textAlign: pw.TextAlign.center),
                );
              }),
            ));
            //Content
            int sumD = 0;
            int sumC = 0;
            tableLignes.addAll(List.generate(file.fileLines.length, (index) {
              return pw.TableRow(
                children: List.generate(headerList.length, (i) {
                  //match with the appropriate header
                  if (file.fileLines[index]['ligne'].keys.toList().length ==
                      headerListInitial.length) {
                    //if the content match the same length
                    //Utils.log(
                    //  "in map currently ${file.inFile[index]['ligne'].keys.toList()[i]} and in cell is ${headerListInitial[i]}");
                    if (file.fileLines[index]['ligne'].keys.toList()[i] ==
                        headerListInitial[i]) {
                      Utils.log(
                          "header is ${headerListInitial[i]} file.fileLines[index]['ligne']['TRAN_TYPE~6'] == D? ${file.fileLines[index]['ligne']['TRAN_TYPE~6'] == "D"} : file.fileLines[index]['ligne']['TRAN_TYPE~6'] ==C? ${file.fileLines[index]['ligne']['TRAN_TYPE~6'] == "C"} ");
                      //Summing the differents amounts in the file
                      if (headerListInitial[i] == "TRAN_TYPE~6" &&
                          file.fileLines[index]['ligne']['TRAN_TYPE~6'] ==
                              "D") {
                        sumD += int.parse(
                            file.fileLines[index]['ligne']['AMOUNT~3']);
                        Utils.log("somme debit is $sumD");
                      } else if (headerListInitial[i] == "TRAN_TYPE~6" &&
                          file.fileLines[index]['ligne']['TRAN_TYPE~6'] ==
                              "C") {
                        sumC += int.parse(
                            file.fileLines[index]['ligne']['AMOUNT~3']);
                        Utils.log("somme debit is $sumC");
                      }
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

            dataBloc
                .add(SetTotalValues({"totalDebit": sumD, "totalCredit": sumC}));

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

  List<Widget> generateFileWidgets(Size appB) {
    List<Widget> l = List.generate(dataBloc.processedFiles.length, (i) {
      // File inFile = MemoryFileSystem().file('original.pdf')
      //   ..writeAsBytesSync(utf8.encode(
      //       dataBloc.processedFiles[i].inFile['data']));
      // Utils.log(inFile.readAsBytesSync());
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
                                        Utils.log(
                                            'now should wait for 3 seconds before requesting update from server');
                                        dataBloc.add(PreparingFileFetching());
                                        Timer(Duration(milliseconds: 100), () {
                                          dataBloc.add(FetchFilesForConfig(
                                              dataBloc.currentConfigName,
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
                                      Utils.log(
                                          'now should wait for 3 seconds before requesting update from server');
                                      dataBloc.add(PreparingFileFetching());
                                      Timer(Duration(milliseconds: 100), () {
                                        dataBloc.add(FetchFilesForConfig(
                                            dataBloc.currentConfigName,
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
                        if (docInitial != null) {
                          alertBloc.add(ShowAlert(
                              whatToShow: null,
                              isDoc: true,
                              doc: docInitial[i],
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
                              title: Expanded(
                                  child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [Text('Original file $windex')],
                              ))));
                          _showToast(kIsWeb
                              ? "Use the mouse wheel to zoom in or out on the area of interest"
                              : "Pinch with your fingers to zoom in or out of the document");
                        } else {
                          _showToast(
                              "Please wait while we are building the file");
                          Timer(Duration(milliseconds: 500), () async {
                            var map = {
                              "which": "original",
                              "dataBloc": dataBloc,
                            };
                            var docI = await compute(_buildDocument, map);
                            setState(() {
                              docInitial = docI;
                              _showToast(
                                  "The file is now ready.Tap the button to view it");
                            });
                          });
                        }
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
                        if (docGenerated != null) {
                          alertBloc.add(ShowAlert(
                              whatToShow: null,
                              isDoc: true,
                              doc: docGenerated[i],
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
                              title: Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text('Generated file $windex'),
                                    Spacer(),
                                    dataBloc.currentConfigName == "CANAL"
                                        ? Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                      text:
                                                          'Total amount debited: ',
                                                      style: const TextStyle(color: Colors.black),
                                                      children: [
                                                        TextSpan(
                                                            text:
                                                                '${dataBloc.popupValues['totalDebited']}')
                                                      ]),
                                                ),
                                                SizedBox(width: 20.0),
                                                RichText(
                                                  text: TextSpan(
                                                      text:
                                                          'Total amount left to debit: ',
                                                      style: const TextStyle(color: Colors.black),
                                                      children: [
                                                        TextSpan(
                                                            text:
                                                                '${dataBloc.popupValues['totalLeftDebit']}')
                                                      ]),
                                                ),
                                              ],
                                            ),
                                          )
                                        : dataBloc.currentConfigName == "SAGE"
                                            ? Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    RichText(
                                                      text: TextSpan(
                                                          text:
                                                              'Total amount debited: ',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                          children: [
                                                            TextSpan(
                                                                text:
                                                                    '${dataBloc.popupValues['totalDebit']}',
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold))
                                                          ]),
                                                    ),
                                                    SizedBox(width: 20.0),
                                                    RichText(
                                                      text: TextSpan(
                                                          text:
                                                              'Total amount credited: ',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                          children: [
                                                            TextSpan(
                                                                text:
                                                                    '${dataBloc.popupValues['totalCredit']}',
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold))
                                                          ]),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container()
                                  ],
                                ),
                              )));
                          _showToast(kIsWeb
                              ? "Use the mouse wheel to zoom in or out on the area of interest"
                              : "Pinch with your fingers to zoom in or out of the document");
                        } else {
                          _showToast(
                              "Please wait while we are building the file");
                          Timer(Duration(milliseconds: 500), () async {
                            var map = {
                              "which": "generated",
                              "dataBloc": dataBloc
                            };
                            Utils.log(
                                "content of context is ${context != null}");
                            var docG = await compute(_buildDocument, map);
                            setState(() {
                              docGenerated = docG;
                              _showToast(
                                  "The file is now ready.Tap the button to view it");
                            });
                          });
                        }
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
                    title: Text("Discard this file ?"),
                    whatToShow: Text(
                        "Do you really want to discard this file ? the file along with any ongoing validation will be removed from the processing pipeline."),
                    actions: [
                      FlatButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "CANCEL",
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      FlatButton(
                          onPressed: () {
                            Utils.log("i index $i");
                            Navigator.of(context).pop();
                            dataBloc.add(DiscardFiles(
                                files: [dataBloc.processedFiles[--windex]],
                                initiatorId: authBloc.user.id));
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
      if (dataBloc.currentControlValidation != null)
        ValidatingProcess(
          whichProcess: "CONTROLLER",
        ),
      if (dataBloc.currentValidation != null)
        ValidatingProcess(
          whichProcess: "VALIDATOR",
        ),
      Container(
        child: BlocBuilder<DataBloc, DataState>(
          builder: (context, state) {
            if (state is FilesDownloaded) {
              //trigger the download
              if (kIsWeb) {
                for (int i = 0; i < state.urlList.length; i++) {
                  final content = "kilo";
                  Utils.log("file url is ${state.urlList[i]}");
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
            return dataBloc.currentControlValidation != null &&
                    dataBloc.currentValidation != null &&
                    dataBloc.currentControlValidation.initiatorId ==
                        authBloc.user.id &&
                    dataBloc.currentConfig.functionnalityTypes
                        .contains("CONTROL") //Initiator when validation started
                ? RaisedButton(
                    onPressed: dataBloc.validationProgress == 100 &&
                            dataBloc.validationControlProgress == 100
                        ? () => Utils.log("can send the file to destinataire")
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
                : (dataBloc.currentValidation != null ||
                            dataBloc.currentControlValidation != null) &&
                        dataBloc.currentControlValidation.initiatorId !=
                            authBloc.user.id &&
                        dataBloc.currentConfig.functionnalityTypes
                            .contains("VALIDATIONS") // Controllers Validators
                    ? Container(
                        width: 500,
                        child: ButtonBar(
                          alignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: MediaQuery.of(context).orientation ==
                                      Orientation.portrait
                                  ? appB.width
                                  : appB.width * 0.5,
                              height: 40.0,
                              child: RaisedButton(
                                onPressed: () {
                                  alertBloc.add(ShowAlert(
                                    title: Text("Are you sure ?"),
                                    whatToShow: Container(
                                      height: 300,
                                      child: Column(
                                        children: [
                                          Text(
                                              "You have decided to reject the current file(s) processed.Would you please state the reason in the field below ?"),
                                          SizedBox(height: 20.0),
                                          TextField(
                                              controller: _rejectionController,
                                              maxLines: 5,
                                              decoration: InputDecoration(
                                                suffixIcon: Icon(
                                                  Icons.person_outline,
                                                  color: Assets.ubaRedColor,
                                                ),
                                                labelText: "what happened ?",
                                                labelStyle: TextStyle(
                                                  color: Assets.ubaRedColor,
                                                  fontSize: 15.0,
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Assets.ubaRedColor,
                                                  ),
                                                ),
                                              )),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      FlatButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          _rejectionController.clear();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "CANCEL",
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      FlatButton(
                                          onPressed: () {
                                            dataBloc.add(UpdateValidation(
                                                authBloc.user.id,
                                                "REJECTED",
                                                authBloc.user.role,
                                                dataBloc.currentConfigName,
                                                authBloc.user.creatorId,
                                                rejectionMotive:
                                                    _rejectionController.text));
                                            Navigator.of(context).pop();
                                          },
                                          child: Container(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text("CONFIRM")))
                                    ],
                                  ));
                                },
                                color: Colors.black,
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
                            ),
                            Container(
                              width: MediaQuery.of(context).orientation ==
                                      Orientation.portrait
                                  ? appB.width
                                  : appB.width * 0.5,
                              height: 40.0,
                              child: RaisedButton(
                                onPressed: () {
                                  dataBloc.add(UpdateValidation(
                                      authBloc.user.id,
                                      "OK",
                                      authBloc.user.role,
                                      dataBloc.currentConfigName,
                                      authBloc.user.creatorId));
                                },
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
                            ),
                          ],
                        ),
                      )
                    : (dataBloc.currentValidation == null ||
                                dataBloc.currentControlValidation == null) &&
                            dataBloc.currentConfig.functionnalityTypes.contains(
                                "VALIDATIONS") //Initiator when validation hasnt started yet
                        ? RaisedButton(
                            onPressed: () {
                              if (dataBloc.currentControlValidation == null) {
                                alertBloc.add(ShowAlert(
                                    whatToShow: ValidationSteps(
                                        defaultRole: "CONTROLLER"),
                                    isDoc: false,
                                    doc: null,
                                    actions: [
                                      FlatButton(
                                        onPressed: () {
                                          alertBloc.add(CloseAlert());
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text("CLOSE")),
                                      ),
                                      FlatButton(
                                        onPressed: () {
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
                                                        color:
                                                            Assets.ubaRedColor,
                                                        size: 80.0),
                                                  ),
                                                  SizedBox(height: 10.0),
                                                  Text(
                                                    "Please wait...",
                                                    textAlign: TextAlign.center,
                                                  )
                                                ],
                                              ),
                                            ),
                                            isDoc: false,
                                            title: Container(),
                                            actions: [],
                                          ));
                                          dataBloc.add(SubmitApprovalChain());
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text("SEND NOTIFICATION")),
                                      ),
                                    ],
                                    title: Text('Create the approval chain')));
                                _showToast(
                                    "Add or remove controllers email ids. Each of them will be notified to approve of the file");
                              } else if (dataBloc.validationControlProgress ==
                                      100 &&
                                  dataBloc.currentValidation == null) {
                                alertBloc.add(ShowAlert(
                                    whatToShow: ValidationSteps(
                                      defaultRole: "VALIDATOR",
                                    ),
                                    isDoc: false,
                                    doc: null,
                                    actions: [
                                      FlatButton(
                                        onPressed: () {
                                          alertBloc.add(CloseAlert());
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text("CLOSE")),
                                      ),
                                      FlatButton(
                                        onPressed: () {
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
                                                        color:
                                                            Assets.ubaRedColor,
                                                        size: 80.0),
                                                  ),
                                                  SizedBox(height: 10.0),
                                                  Text(
                                                    "Please wait...",
                                                    textAlign: TextAlign.center,
                                                  )
                                                ],
                                              ),
                                            ),
                                            isDoc: false,
                                            title: Container(),
                                            actions: [],
                                          ));
                                          dataBloc.add(SubmitApprovalChain());
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text("SEND NOTIFICATION")),
                                      ),
                                    ],
                                    title: Text('Create the approval chain')));
                                _showToast(
                                    "Add or remove validators email ids. Each of them will be notified to approve of the file");
                              } else {
                                alertBloc.add(ShowAlert(
                                    whatToShow: Text(
                                        "Some approvals are still required to move forward !"),
                                    isDoc: false,
                                    doc: null,
                                    actions: [
                                      FlatButton(
                                        onPressed: () {
                                          alertBloc.add(CloseAlert());
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text("CLOSE")),
                                      ),
                                    ]));
                              }
                            },
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
                            //last button which download files
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
    // Timer(Duration(milliseconds: 500), () {
    //   _showToast("Please wait while we are building the file(s)");
    // });
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
                    "${dataBloc.currentConfigName == "CANAL" ? 'CANAL+' : dataBloc.currentConfigName}\nFile processing control",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Assets.ubaRedColor,
                      fontSize: 50.0,
                    ),
                  ),
                  SizedBox(height: 50.0),
                  if (dataBloc.currentConfigName == "CANAL")
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
                          Utils.log("updating file list UI");
                        });
                      }
                      if (state is ValidationProcessLoaded) {
                        setState(() {});
                      }
                      if (state is ValidationUpdated) {
                        alertBloc.add(ShowAlert(
                          title: Text("Thank you"),
                          whatToShow: Text(
                              "You will now be logged out and redirected to the login screen\n\nAre you done ?"),
                          actions: [
                            FlatButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "CANCEL",
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                            FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  authBloc.add(LogOut());
                                },
                                child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("LEAVE APP")))
                          ],
                        ));
                      }
                      if (state is ValidationUpdateFailed) {
                        alertBloc.add(ShowAlert(
                          title: Text("Ooops... "),
                          whatToShow: Text(state.message),
                          actions: [
                            FlatButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "OK",
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ));
                      }
                    },
                    child: Container(
                      padding: Responsive.isMobile(context)
                          ? const EdgeInsets.symmetric(horizontal: 30.0)
                          : const EdgeInsets.all(0),
                      child: Column(
                        children: generateFileWidgets(appB),
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
