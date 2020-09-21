import 'package:equatable/equatable.dart';

abstract class DocState extends Equatable {
  const DocState();
  @override
  List<Object> get props => [];
}

class DocInit extends DocState {}

class DocLoading extends DocState {}

class TotalPages extends DocState {
  final int total;
  const TotalPages({this.total});
  @override
  List<Object> get props => [total];
}

class ChangePage extends DocState {
  final int page;
  const ChangePage({this.page});
  @override
  List<Object> get props => [page];
}
