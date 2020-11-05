import 'package:equatable/equatable.dart';
import 'package:sfp/src/models/models.dart';

abstract class DataEvent extends Equatable {
  const DataEvent();
  @override
  List<Object> get props => [];
}

class FetchConfigs extends DataEvent {
  const FetchConfigs();
}

class PreparingFileFetching extends DataEvent {}

class FetchFilesForConfig extends DataEvent {
  final String configName;
  final String userId;
  const FetchFilesForConfig(this.configName, this.userId);
}

class UpdateValidation extends DataEvent {
  final String validatorId;
  final String validation;
  final String validationType;
  final String configName;
  final String initiatorId;
  final String rejectionMotive;
  const UpdateValidation(this.validatorId, this.validation, this.validationType,
      this.configName, this.initiatorId,
      {this.rejectionMotive});
}

class FetchFilesToValidate extends DataEvent {
  final String fileProcessId;
  const FetchFilesToValidate(this.fileProcessId);
}

class SelectConfig extends DataEvent {
  final int configPosition;
  const SelectConfig(this.configPosition);
  List<Object> get props => [configPosition];
}

class StartFinalMailProcedure extends DataEvent {}

class SendFinalMail extends DataEvent {
  final String configName;
  final String username;
  final String userId;
  final String to;
  final List<String> enCopie;
  final List<String> processingIds;
  const SendFinalMail(this.configName, this.username, this.userId, this.to,
      this.enCopie, this.processingIds);
}

class DoFileUpload extends DataEvent {
  final files;
  final String userId;
  const DoFileUpload(this.files, this.userId);
  List<Object> get props => [files, userId];
}

class SubmitApprovalChain extends DataEvent {}

class CreateUserWithRole extends DataEvent {
  final String username;
  final String userId;
  final String processingId;
  final List<String> mailOfUsers;
  final List<String> filenames;
  final files;
  final String role;
  final String configName;

  const CreateUserWithRole(
      {this.username,
      this.userId,
      this.processingId,
      this.mailOfUsers,
      this.filenames,
      this.files,
      this.role,
      this.configName});
  List<Object> get props => [
        username,
        userId,
        processingId,
        mailOfUsers,
        filenames,
        files,
        role,
        configName
      ];
}

class GetValidationProcess extends DataEvent {
  final String initiatorId;
  final String configName;
  final String whichValidators;
  const GetValidationProcess(
      {this.initiatorId, this.configName, this.whichValidators});
  List<Object> get props => [initiatorId, configName, whichValidators];
}

class PutFormInStandBy extends DataEvent {}

class DownloadFiles extends DataEvent {
  final String userId;
  final String configName;
  const DownloadFiles(this.userId, this.configName);
  List<Object> get props => [userId, configName];
}

class DiscardFiles extends DataEvent {
  final List<ProcessedFileModel> files;
  final String initiatorId;
  const DiscardFiles({this.files, this.initiatorId});
  List<Object> get props => [files, initiatorId];
}

class SetTotalValues extends DataEvent {
  final Map<String, dynamic> values;
  const SetTotalValues(this.values);
}
