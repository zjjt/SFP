import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum AlertDialogStatus { opened, closed }

class AlertState extends Equatable {
  final AlertDialogStatus status;
  final Widget whatToShow;
  final bool isDoc;
  final Uint8List doc;
  final String title;
  final List<Widget> actions;
  final Alignment alignement;

  const AlertState._(
      {this.status = AlertDialogStatus.closed,
      this.whatToShow,
      this.isDoc,
      this.doc,
      this.title,
      this.actions,
      this.alignement});
  const AlertState.closed() : this._();
  const AlertState.opened(Widget whatToShow, bool isDoc, Uint8List doc,
      String title, List<Widget> actions, Alignment alignement)
      : this._(
            status: AlertDialogStatus.opened,
            whatToShow: whatToShow,
            isDoc: isDoc,
            doc: doc,
            title: title,
            actions: actions,
            alignement: alignement);
  @override
  List<Object> get props =>
      [status, whatToShow, isDoc, doc, title, actions, alignement];
}
