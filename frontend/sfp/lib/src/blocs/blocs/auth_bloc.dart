import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfp/src/models/process_config_model.dart';
import 'package:sfp/src/resources/repository.dart';

import '../blocs.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Repository repo;
  List<ProcessConfigModel> processConfigs;
  AuthBloc(this.repo) : super(const AuthState.unknown());

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is LoggingIn) {
      print(
          'trying to login with username:${event.username} and ${event.password}');
      try {
        yield DataLoading();
        final configs = await repo.fetchConfig();
        processConfigs = configs;
        yield ConfigOK(configs);
      } on NetWorkException {
        yield DataFailure("Aucune connexion internet détectée");
      }
    }
    //if(event is )
  }
}
