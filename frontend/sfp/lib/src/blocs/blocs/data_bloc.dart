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
      try {
        yield DataLoading();
        final configs = await repo.fetchConfig();
        processConfigs = configs;
        yield ConfigOK(configs);
      } on NetWorkException {
        yield DataFailure("No internet connection");
      }
    }
    //if(event is )
  }

  @override
  void onEvent(DataEvent event) {
    print(event);
    super.onEvent(event);
  }

  @override
  void onChange(Change<DataState> change) {
    print(change);
    super.onChange(change);
  }

  @override
  void onTransition(Transition<DataEvent, DataState> transition) {
    print(transition);
    super.onTransition(transition);
  }
}
