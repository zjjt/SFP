import 'package:equatable/equatable.dart';

abstract class DataEvent extends Equatable {
  const DataEvent();
  @override
  List<Object> get props => [];
}

class FetchConfigs extends DataEvent {
  const FetchConfigs();
}
