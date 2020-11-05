import 'dart:convert';

import 'package:sfp/src/models/models.dart';
import 'package:sfp/src/resources/resources.dart';
import 'package:sfp/utils.dart';

class Repository {
  Future<List<ProcessConfigModel>> fetchConfig(String configName) async {
    List<ProcessConfigModel> configs;
    try {
      configs = await netProvider.fetchConfig(configName);
    } on NetWorkException {
      Utils.log("couldnt reach the api");
      return null;
    }
    //Utils.log(configs);
    return configs;
  }

  Future<Map<String, dynamic>> updateValidation(
      String validatorId,
      String validation,
      String validationType,
      String configName,
      String initiatorId,
      String rejectionMotive) async {
    try {
      return await netProvider.updateValidation(validatorId, validation,
          validationType, configName, initiatorId, rejectionMotive);
    } on NetWorkException {
      Utils.log("couldnt reach the api");
      return null;
    }
  }

  Future<bool> sendFinalMail(String configName, String username, String userId,
      String to, List<String> enCopie, List<String> processingIds) async {
    try {
      return await netProvider.sendFinalMail(
        configName,
        username,
        userId,
        to,
        enCopie,
        processingIds,
      );
    } on NetWorkException {
      Utils.log("couldnt reach the api");
      return null;
    }
  }

  Future<Map<String, dynamic>> fetchUsers(
      String username, String password) async {
    var users;
    try {
      users = await netProvider.fetchUsers(username,
          username.contains("admin") ? password : _encodeToBase64(password));
    } on NetWorkException {
      Utils.log("couldnt reach the api");
      return null;
    }
    return users;
  }

  Future<Map<String, dynamic>> deleteFilesById(
      List<ProcessedFileModel> files) async {
    var del;
    try {
      del = await netProvider.deleteFilesById(files);
    } on NetWorkException {
      Utils.log("couldnt reach the api ${del.message}");
      return null;
    }
    return del;
  }

  Future<Map<String, dynamic>> deleteValidationProcess(
      String configName, String initiatorId) async {
    var del;
    try {
      del = await netProvider.deleteValidationProcess(
          configName, initiatorId, "CONTROLLER");
      if (del != null) {
        del = await netProvider.deleteValidationProcess(
            configName, initiatorId, "VALIDATOR");
      }
    } on NetWorkException {
      Utils.log("couldnt reach the api ${del.message}");
      return null;
    }
    return del;
  }

  Future<Map<String, dynamic>> uploadFiles(List<dynamic> files,
      String configName, String userId, String extension) async {
    var fup;
    try {
      fup = await netProvider.uploadFiles(files, configName, userId, extension);
    } on NetWorkException {
      Utils.log("couldnt reach the api ${fup.message}");
      return null;
    }
    return fup;
  }

  Future<Map<String, dynamic>> fetchCurrentProcessingFiles(
      String configName, String userId) async {
    var files;
    try {
      files = await netProvider.fetchCurrentProcessingFiles(configName, userId);
    } on NetWorkException {
      Utils.log("couldnt reach the api ${files.message}");
      return null;
    }
    return files;
  }

  Future<Map<String, dynamic>> fetchCurrentProcessingFilesToValidate(
      String fileId) async {
    var files;
    try {
      files = await netProvider.fetchCurrentProcessingFilesToValidate(fileId);
    } on NetWorkException {
      Utils.log("couldnt reach the api ${files.message}");
      return null;
    }
    return files;
  }

  Future<Map<String, dynamic>> createUsersWithRole(
      String username,
      String userId,
      String fileId,
      List<String> userMails,
      List<dynamic> files,
      String role,
      String configName) async {
    var val;
    try {
      val = await netProvider.createUsersWithRole(
          username, userId, fileId, userMails, files, role, configName);
    } on NetWorkException {
      Utils.log("couldnt reach the api ${val.message}");
      return null;
    }
    return val;
  }

  Future<Map<String, dynamic>> getCurrentValidationProcess(
      String initiatorId, String configName, String whichValidator) async {
    var val;
    try {
      val = await netProvider.getCurrentValidationProcess(
          initiatorId, configName, whichValidator);
    } on NetWorkException {
      Utils.log("couldnt reach the api ${val.message}");
      return null;
    }
    return val;
  }

  Future<Map<String, dynamic>> getValidatorNames(
      List<String> ids, String validatorType) async {
    var names;
    try {
      names = await netProvider.getValidatorNames(ids, validatorType);
    } on NetWorkException {
      Utils.log("couldnt reach the api ${names.message}");
      return null;
    }
    return names;
  }

  Future<List<String>> downloadFilesPath(
      String userId, String configName) async {
    var filesPath;
    try {
      filesPath = await netProvider.downloadFilesPath(userId, configName);
    } on NetWorkException {
      Utils.log("couldnt reach the api ${filesPath.message}");
      return null;
    }
    return filesPath;
  }

  Future<bool> logOut(String username) async {
    bool result = false;
    try {
      result = await netProvider.logOut(username);
    } on NetWorkException {
      Utils.log("couldnt reach the api");
      return null;
    }
    return result;
  }

  String _encodeToBase64(String password) {
    var bytes = utf8.encode(password);
    return base64Encode(bytes);
  }
}

//Custom Exceptions
class NetWorkException implements Exception {}
