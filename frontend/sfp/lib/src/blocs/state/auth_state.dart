import 'package:equatable/equatable.dart';
import 'package:sfp/src/models/user_model.dart';

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel user;
  const AuthState._({this.status = AuthStatus.unknown, this.user});
  const AuthState.unknown() : this._();
  const AuthState.loading() : this._(status: AuthStatus.loading);
  const AuthState.authenticated(UserModel user)
      : this._(status: AuthStatus.authenticated, user: user);
  const AuthState.unauthenticated({String msg})
      : this._(status: AuthStatus.unauthenticated);
  @override
  List<Object> get props => [status, user];
}

enum AuthStatus { unknown, loading, authenticated, unauthenticated }
