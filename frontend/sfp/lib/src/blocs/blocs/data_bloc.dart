import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfp/src/models/process_config_model.dart';
import 'package:sfp/src/resources/repository.dart';

import '../blocs.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  final Repository repo;
  List<ProcessConfigModel> processConfigs;
  DataBloc(this.repo) : super(DataInitial());

  @override
  Stream<DataState> mapEventToState(DataEvent event) async* {
    if (event is FetchConfigs) {
      print('dispatching FetchConfigs Event');
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
