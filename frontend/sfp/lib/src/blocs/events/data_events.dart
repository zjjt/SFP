import 'package:equatable/equatable.dart';

abstract class DataEvent extends Equatable {
  const DataEvent();
  @override
  List<Object> get props => [];
}

class FetchConfigs extends DataEvent {
  const FetchConfigs();
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
