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
  Map<String, String> validatorsName;
  Map<String, String> controllersName;
  ProcessConfigModel currentConfig;
  String currentConfigName = "";
  ProcessValidationModel currentValidation;
  ProcessControlValidationModel currentControlValidation;
  double validationProgress = 0;
  double validationControlProgress = 0;
  Map<String, dynamic> popupValues = {};

  DataBloc(this.repo) : super(DataInitial());

  double _calculateProgress(Map<String, dynamic> validat) {
    double p = 0;
    Map<String, dynamic> validations = validat;
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
        final configs = await repo.fetchConfig("");
        processConfigs = configs;
        yield ConfigLoaded(configs);
      } on NetWorkException {
        yield DataFailure("No internet connection");
      }
    }

    if (event is SetTotalValues) {
      popupValues = event.values;
      yield TotalValuesSet();
    }

    if (event is SelectConfig) {
      currentConfig = processConfigs[event.configPosition];
      currentConfigName = currentConfig.configName;
      Utils.log("selected config is $currentConfig");
      yield ConfigSelected(currentConfig);
    }

    if (event is StartFinalMailProcedure) {
      yield FinalMailProcedureStarted();
    }

    if (event is SendFinalMail) {
      try {
        yield DataLoading();
        var mailsent = await repo.sendFinalMail(
            event.configName,
            event.username,
            event.userId,
            event.to,
            event.enCopie,
            event.processingIds);
        Utils.log("mailsent? $mailsent");
        if (mailsent) {
          Utils.log("dispatching final mail sent");
          yield FinalMailSent();
        } else {
          yield FinalMailNotSent();
        }
      } on NetWorkException {
        yield DataFailure("No internet connection");
      }
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
      //here we first try to check if there exists a CONTROLLER validation process first
      // and after we look for a VALIDATOR validation process
      yield DataLoading();
      try {
        //Getting Controllers
        final valC = await repo.getCurrentValidationProcess(
            event.initiatorId, event.configName, "CONTROLLER");
        Utils.log(valC["processValidation"]);
        if (valC["processValidation"] != null) {
          controllersName = {};
          currentControlValidation =
              ProcessControlValidationModel.fromJSON(valC["processValidation"]);
          validationControlProgress =
              _calculateProgress(currentControlValidation.validators);
          var names = await repo.getValidatorNames(
              currentControlValidation.validators.keys.toList(), "CONTROLLER");
          if (names['usernames'].length > 0) {
            for (int i = 0;
                i < currentControlValidation.validators.keys.toList().length;
                i++) {
              controllersName.putIfAbsent(
                  currentControlValidation.validators.keys.toList()[i],
                  () => names['usernames'][i]);
            }
          }
        }
        //Getting validators
        final valP = await repo.getCurrentValidationProcess(
            event.initiatorId, event.configName, "VALIDATOR");
        Utils.log(valP["processValidation"]);
        if (valP["processValidation"] != null) {
          validatorsName = {};
          currentValidation =
              ProcessValidationModel.fromJSON(valP["processValidation"]);
          validationProgress = _calculateProgress(currentValidation.validators);
          var names = await repo.getValidatorNames(
              currentValidation.validators.keys.toList(), "VALIDATOR");
          if (names['usernames'].length > 0) {
            for (int i = 0;
                i < currentValidation.validators.keys.toList().length;
                i++) {
              validatorsName.putIfAbsent(
                  currentValidation.validators.keys.toList()[i],
                  () => names['usernames'][i]);
            }
          }
        }
        yield ValidationProcessLoaded(
            processValidation: currentValidation,
            processControlValidation: currentControlValidation,
            type: currentControlValidation != null
                ? "CONTROLLER"
                : currentValidation != null
                    ? "VALIDATOR"
                    : "CONTROLLER");
      } on NetWorkException {
        yield DataFailure("No internet connection");
      }
    }

    if (event is DiscardFiles) {
      if (event.files.isNotEmpty) {
        //removing from local state variable
        event.files.forEach((element) => processedFiles.remove(element));
        if (processedFiles.isEmpty) {
          try {
            await repo.deleteFilesById(event.files);
            await repo.deleteValidationProcess(
                currentConfig.configName, event.initiatorId);
            currentValidation = null;
            currentControlValidation = null;
          } on NetWorkException {
            yield DataFailure("No internet connection");
          }
          yield AllFilesDiscarded();
        } else {
          try {
            var r = await repo.deleteFilesById(event.files);
            if (currentValidation != null) {
              await repo.deleteValidationProcess(
                  currentConfig.configName, event.initiatorId);
              currentValidation = null;
            }
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
      final conf = await repo.fetchConfig(m['fichiers'][0]['configName']);
      if (conf.length > 0) {
        currentConfig = conf.first;
      }
      for (int i = 0; i < m['fichiers'].length; i++) {
        Utils.log(m['fichiers'].length);
        Utils.log(m['fichiers'][i]['configName']);
        currentConfigName = m['fichiers'][i]['configName'];
        var pf = ProcessedFileModel.fromJSON(m['fichiers'][i]);
        processedFiles.add(pf);
      }
      Utils.log("processed files number ${processedFiles.length}");
      yield FileLoaded(fcount: processedFiles.length);
    }

    if (event is UpdateValidation) {
      yield DataLoading();
      final m = await repo.updateValidation(
          event.validatorId,
          event.validation,
          event.validationType,
          event.configName,
          event.initiatorId,
          event.rejectionMotive);
      if (m['errors']) {
        yield ValidationUpdateFailed(m['message']);
      } else {
        yield ValidationUpdated();
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
