import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class AlertEvent extends Equatable {
  const AlertEvent();
  @override
  List<Object> get props => [];
}

class ShowAlert extends AlertEvent {
  final Widget whatToShow;
  final bool isDoc;
  final Uint8List doc;
  final String title;
  final List<Widget> actions;
  final Alignment alignement;

  const ShowAlert(
      {this.whatToShow,
      this.isDoc = false,
      this.doc,
      this.title,
      this.actions,
      this.alignement});
  List<Object> get props => [whatToShow];
}

class CloseAlert extends AlertEvent {}
