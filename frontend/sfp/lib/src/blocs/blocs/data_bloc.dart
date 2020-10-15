import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfp/src/models/models.dart';
import 'package:sfp/src/models/process_config_model.dart';
import 'package:sfp/src/models/process_validation_model.dart';
import 'package:sfp/src/resources/repository.dart';
import 'package:sfp/utils.dart';

import '../blocs.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  final Repository repo;
  List<ProcessConfigModel> processConfigs;
  List<ProcessedFileModel> processedFiles;
  ProcessConfigModel currentConfig;
  ProcessValidationModel currentValidation;
  double validationProgress;

  DataBloc(this.repo) : super(DataInitial());

  double _calculateProgress() {
    double p = 0;
    Map<String, dynamic> validations = currentValidation.validators;
    if (validations != null || validations.isNotEmpty) {
      int nbrValidators = validations.keys.length;
      int nbrValidated = 0;
      validations.forEach((key, value) {
        if (value.toString().contains("OK")) {
          nbrValidated++;
        }
      });
      if (nbrValidated == nbrValidators) {
        p = 100;
      } else {
        p = (nbrValidated * 100) / nbrValidators;
      }
    }
    Utils.log("current validation progress is ${p.roundToDouble()}");
    return p.roundToDouble();
  }

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
      Utils.log("selected config is $currentConfig");
      yield ConfigSelected(currentConfig);
    }

    if (event is DownloadFiles) {
      try {
        List<String> urlList =
            await repo.downloadFilesPath(event.userId, event.configName);
        yield FilesDownloaded(urlList: urlList);
      } on NetWorkException {
        yield DataFailure("No internet connection");
      }
    }

    if (event is SubmitApprovalChain) {
      yield ApprovalChainSubmited();
    }
    if (event is PutFormInStandBy) {
      yield StandByFormRequested();
    }

    if (event is CreateUserWithRole) {
      yield DataLoading();
      try {
        final result = await repo.createUsersWithRole(
            event.username,
            event.userId,
            event.processingId,
            event.mailOfUsers,
            event.files,
            event.role,
            event.configName);
        if (!result['errors']) {
          yield UsersCreated();
        } else {
          yield DataFailure(
              "The approval chain couldn't be created. A unexpected problem occured.");
        }
      } on NetWorkException {
        yield DataFailure("No internet connection");
      }
    }

    if (event is GetValidationProcess) {
      yield DataLoading();
      try {
        final val = await repo.getCurrentValidationProcess(
            event.initiatorId, event.configName);
        currentValidation = val["processValidation"];
        validationProgress = _calculateProgress();
      } on NetWorkException {
        yield DataFailure("No internet connection");
      }
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

    if (event is PreparingFileFetching) {
      yield FileFetching();
    }
    if (event is FetchFilesForConfig) {
      final m = await repo.fetchCurrentProcessingFiles(
          event.configName, event.userId);
      processedFiles = [];
      for (int i = 0; i < m['fichiers'].length; i++) {
        Utils.log(m['fichiers'].length);
        Utils.log(m['fichiers'][i]['configName']);
        var pf = ProcessedFileModel.fromJSON(m['fichiers'][i]);
        processedFiles.add(pf);
      }
      Utils.log("processed files number ${processedFiles.length}");
      yield FileLoaded(fcount: processedFiles.length);
    }
    if (event is FetchFilesToValidate) {
      final m =
          await repo.fetchCurrentProcessingFilesToValidate(event.fileProcessId);
      processedFiles = [];
      for (int i = 0; i < m['fichiers'].length; i++) {
        Utils.log(m['fichiers'].length);
        Utils.log(m['fichiers'][i]['configName']);
        var pf = ProcessedFileModel.fromJSON(m['fichiers'][i]);
        processedFiles.add(pf);
      }
      Utils.log("processed files number ${processedFiles.length}");
      yield FileLoaded(fcount: processedFiles.length);
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
            Utils.log(m['fichiers'].length);
            Utils.log(m['fichiers'][i]['configName']);
            var pf = ProcessedFileModel.fromJSON(m['fichiers'][i]);
            processedFiles.add(pf);
          }
          Utils.log("processed files number ${processedFiles.length}");
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
    Utils.log(event);
    super.onEvent(event);
  }

  @override
  void onChange(Change<DataState> change) {
    Utils.log(change);
    super.onChange(change);
  }

  @override
  void onTransition(Transition<DataEvent, DataState> transition) {
    Utils.log(transition);
    super.onTransition(transition);
  }
}
