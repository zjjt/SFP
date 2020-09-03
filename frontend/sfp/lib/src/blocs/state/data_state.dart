import 'package:equatable/equatable.dart';

abstract class DataState extends Equatable {
  const DataState();
  @override
  List<Object> get props => [];
}

class DataInitial extends DataState {
  @override
  String toString() => 'initial state of the app';
}

class DataFailure extends DataState {
  String toString() => 'an error occured while fetching the data';
}
