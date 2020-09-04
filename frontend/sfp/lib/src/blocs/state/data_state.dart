import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sfp/src/models/process_config_model.dart';

abstract class DataState extends Equatable {
  const DataState();
  @override
  List<Object> get props => [];
}

class DataInitial extends DataState {
  const DataInitial();
  @override
  String toString() => 'emiting DataInitial';
}

class DataLoading extends DataState {
  const DataLoading();
  @override
  String toString() => 'emiting DataLoading';
}

class ConfigOK extends DataState {
  final List<ProcessConfigModel> configs;
  const ConfigOK(this.configs);
  String toString() => 'emiting ConfigOK';
}

class DataFailure extends DataState {
  final String _message;
  const DataFailure(this._message);

  void showError() {
    Fluttertoast.showToast(
        msg: _message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey,
        textColor: Colors.black,
        fontSize: 12.0);
    print('no internet connetion $_message');
  }

  String toString() => 'emiting DataFailure';
}
