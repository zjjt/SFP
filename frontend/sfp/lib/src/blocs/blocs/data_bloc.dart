import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfp/src/models/process_config_model.dart';
import 'package:sfp/src/resources/repository.dart';

import '../blocs.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  final Repository repo;
  List<ProcessConfigModel> processConfigs;
  ProcessConfigModel currentConfig;
  DataBloc(this.repo) : super(DataInitial());

  @override
  Stream<DataState> mapEventToState(DataEvent event) async* {
    if (event is FetchConfigs) {
      try {
        yield DataLoading();
        final configs = await repo.fetchConfig();
        processConfigs = configs;
        yield ConfigLoaded(configs);
      } on NetWorkException {
        yield DataFailure("No internet connection");
      }
    }
    if (event is SelectConfig) {
      currentConfig = processConfigs[event.configPosition];
      yield ConfigSelected(currentConfig);
    }
    if (event is DoFileUpload) {
      yield FileUploading();
      try {
        if (event.files.isNotEmpty && event.userName.isNotEmpty) {
          //here we call the repository to handle the api post request
          final m = await repo.uploadFiles(
              event.files, currentConfig.configName, event.userName);
          print('fileupload result $m');
          yield FileUploaded(errors: m['errors'], message: m['message']);
        } else {
          yield FileUploaded(
              message:
                  "A problem occured during the file upload.\nMake sure you are selecting the right files",
              errors: true);
        }
      } on NetWorkException {
        yield DataFailure("No internet connection");
      }
    }
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
