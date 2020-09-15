import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfp/src/models/models.dart';
import 'package:sfp/src/models/process_config_model.dart';
import 'package:sfp/src/resources/repository.dart';

import '../blocs.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  final Repository repo;
  List<ProcessConfigModel> processConfigs;
  List<ProcessedFileModel> processedFiles;
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
    if (event is DiscardFiles) {
      if (event.files.isNotEmpty) {
        //removing from local state variable
        event.files.forEach((element) => processedFiles.remove(element));
        if (processedFiles.isEmpty) {
          yield AllFilesDiscarded();
        } else {
          try {
            var r = await repo.deleteFilesById(event.files);
            yield FilesDiscarded(message: r['message'], errors: r['errors']);
          } on NetWorkException {
            yield DataFailure("No internet connection");
          }
        }
      }
    }
    if (event is DoFileUpload) {
      yield FileUploading();
      try {
        if (event.files.isNotEmpty && event.userId.isNotEmpty) {
          //here we call the repository to handle the api post request
          final m = await repo.uploadFiles(
              event.files,
              currentConfig.configName,
              event.userId,
              currentConfig.fileTypeAndSizeInMB['type']);
          processedFiles = [];
          for (int i = 0; i < m['fichiers'].length; i++) {
            print(m['fichiers'].length);
            print(m['fichiers'][i]['configName']);
            var pf = ProcessedFileModel.fromJSON(m['fichiers'][i]);
            processedFiles.add(pf);
          }
          print("processed files number ${processedFiles.length}");
          yield FileUploaded(
              errors: m['errors'],
              message: m['message'],
              processingTime: m['processing_time']);
        } else {
          yield FileUploaded(
              processingTime: '0 milliseconds',
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
