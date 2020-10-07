import 'package:equatable/equatable.dart';
import 'package:sfp/src/models/models.dart';

abstract class DataEvent extends Equatable {
  const DataEvent();
  @override
  List<Object> get props => [];
}

class FetchConfigs extends DataEvent {
  const FetchConfigs();
}

class PreparingFileFetching extends DataEvent {}

class FetchFilesForConfig extends DataEvent {
  final String configName;
  final String userId;
  const FetchFilesForConfig(this.configName, this.userId);
}

class SelectConfig extends DataEvent {
  final int configPosition;
  const SelectConfig(this.configPosition);
  List<Object> get props => [configPosition];
}

class DoFileUpload extends DataEvent {
  final files;
  final String userId;
  const DoFileUpload(this.files, this.userId);
  List<Object> get props => [files, userId];
}

class DownloadFiles extends DataEvent {
  final String userId;
  final String configName;
  const DownloadFiles(this.userId, this.configName);
  List<Object> get props => [userId, configName];
}

class DiscardFiles extends DataEvent {
  final List<ProcessedFileModel> files;
  const DiscardFiles({this.files});
  List<Object> get props => [files];
}
