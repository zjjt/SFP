import 'package:equatable/equatable.dart';

abstract class NavEvent extends Equatable {
  const NavEvent();
  @override
  List<Object> get props => [];
}

class GoLogin extends NavEvent {}

class GoConfig extends NavEvent {}

class GoFupload extends NavEvent {}

class GoAdmin extends NavEvent {}

class GoValidate extends NavEvent {}

class GoResult extends NavEvent {}

class GoTo extends NavEvent {
  final String where;
  const GoTo({this.where});
  List<Object> get props => [where];
}
