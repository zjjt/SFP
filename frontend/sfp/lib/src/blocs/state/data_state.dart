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

class ConfigLoaded extends DataState {
  final List<ProcessConfigModel> configs;
  const ConfigLoaded(this.configs);
  String toString() => 'emiting ConfigLoaded';
}

class ConfigSelected extends DataState {
  final ProcessConfigModel config;
  const ConfigSelected(this.config);
  List<Object> get props => [config];
}

class FileUploaded extends DataState {
  final String message;
  final bool errors;
  final String processingTime;
  const FileUploaded({this.message, this.errors, this.processingTime});
  List<Object> get props => [message, errors, processingTime];
}

class FileLoaded extends DataState {
  final int fcount;
  const FileLoaded({this.fcount});
}

class FileUploading extends DataState {}

class FilesDiscarded extends DataState {
  final String message;
  final bool errors;
  const FilesDiscarded({this.message, this.errors});
}

class AllFilesDiscarded extends DataState {}

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
