import 'package:equatable/equatable.dart';

abstract class DocEvent extends Equatable {
  const DocEvent();
  @override
  List<Object> get props => [];
}

class GetTotalPages extends DocEvent {
  final int pages;
  const GetTotalPages(this.pages);
  @override
  List<Object> get props => [pages];
}

class PageChanged extends DocEvent {
  final int page;
  const PageChanged(this.page);
  @override
  List<Object> get props => [page];
}
