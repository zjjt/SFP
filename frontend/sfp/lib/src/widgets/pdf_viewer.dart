import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:sfp/assets.dart';
import 'package:sfp/src/blocs/blocs.dart';

class PdfViewer extends StatelessWidget {
  final PdfController controller;

  const PdfViewer({Key key, @required this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final docBloc = context.bloc<DocBloc>();
    return Container(
      width: 1000.0,
      child: Stack(children: [
        InteractiveViewer(
          child: PdfView(
            onDocumentLoaded: (document) {
              if (docBloc.totalPages == 0) {
                docBloc.add(GetTotalPages(document.pagesCount));
              }
            },
            onPageChanged: (page) {
              print("page is $page");
              docBloc.add(PageChanged(page));
            },
            pageSnapping: kIsWeb ? false : false,
            scrollDirection: Axis.vertical,
            documentLoader: SpinKitThreeBounce(
              size: 20.0,
              color: Assets.ubaRedColor,
            ),
            controller: controller,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 40.0,
                  height: 40.0,
                  child: RaisedButton(
                    onPressed: () {
                      controller.previousPage(
                          duration: Duration(milliseconds: 250),
                          curve: Curves.easeOut);
                    },
                    color: Assets.ubaRedColor,
                    hoverColor: Colors.black,
                    textColor: Colors.white,
                    child: Text(
                      "<",
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
                SizedBox(width: 5.0),
                Text(
                  "${docBloc.currentPage}/${docBloc.totalPages}",
                  textAlign: TextAlign.center,
                ),
                SizedBox(width: 5.0),
                Container(
                  width: 40.0,
                  height: 40.0,
                  child: RaisedButton(
                    onPressed: () {
                      controller.nextPage(
                          duration: Duration(milliseconds: 250),
                          curve: Curves.easeIn);
                    },
                    color: Assets.ubaRedColor,
                    hoverColor: Colors.black,
                    textColor: Colors.white,
                    child: Text(
                      ">",
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
          ),
        ),
      ]),
    );
  }
}
