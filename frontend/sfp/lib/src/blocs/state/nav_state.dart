import 'package:equatable/equatable.dart';

abstract class NavState extends Equatable {
  const NavState();
  @override
  List<Object> get props => [];
}

class LoginState extends NavState {}

class AdminState extends NavState {}

class FuploadState extends NavState {}

class ResultState extends NavState {}

class SelectConfigState extends NavState {}

class ValidationState extends NavState {}

class WhereTo extends NavState {
  final String where;
  const WhereTo(this.where);
  @override
  List<Object> get props => [where];
}
