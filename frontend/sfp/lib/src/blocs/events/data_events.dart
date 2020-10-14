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

class SelectConfig extends DataEvent {
  final int configPosition;
  const SelectConfig(this.configPosition);
  List<Object> get props => [configPosition];
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
  final List<String> mailOfUsers;
  final String role;
  final String configName;

  const CreateUserWithRole(
      {this.username,
      this.userId,
      this.mailOfUsers,
      this.role,
      this.configName});
  List<Object> get props => [username, userId, mailOfUsers, configName];
}

class GetValidationProcess extends DataEvent {
  final String initiatorId;
  final String configName;
  const GetValidationProcess({this.initiatorId, this.configName});
  List<Object> get props => [initiatorId, configName];
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
  const DiscardFiles({this.files});
  List<Object> get props => [files];
}
