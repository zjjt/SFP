import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class LoggingIn extends AuthEvent {
  final String username;
  final String password;
  const LoggingIn(this.username, this.password);
  @override
  List<Object> get props => [username, password];
}

class LogginOut extends AuthEvent {}
