import 'dart:convert';

import 'package:sfp/src/models/models.dart';
import 'package:sfp/src/resources/resources.dart';

class Repository {
  Future<List<ProcessConfigModel>> fetchConfig() async {
    List<ProcessConfigModel> configs;
    try {
      configs = await netProvider.fetchConfig();
    } on NetWorkException {
      print("couldnt reach the api");
      return null;
    }
    //print(configs);
    return configs;
  }

  Future<Map<String, dynamic>> fetchUsers(
      String username, String password) async {
    var users;
    try {
      users = await netProvider.fetchUsers(username,
          username.contains("admin") ? password : _encodeToBase64(password));
    } on NetWorkException {
      print("couldnt reach the api");
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
      print("couldnt reach the api ${del.message}");
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
      print("couldnt reach the api ${fup.message}");
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
      print("couldnt reach the api ${files.message}");
      return null;
    }
    return files;
  }

  Future<Map<String, dynamic>> createUsersWithRole(
      String username,
      String userId,
      List<String> userMails,
      String role,
      String configName) async {
    var val;
    try {
      val = await netProvider.createUsersWithRole(
          username, userId, userMails, role, configName);
    } on NetWorkException {
      print("couldnt reach the api ${val.message}");
      return null;
    }
    return val;
  }

  Future<Map<String, dynamic>> getCurrentValidationProcess(
      String initiatorId, String configName) async {
    var val;
    try {
      val = await netProvider.getCurrentValidationProcess(
          initiatorId, configName);
    } on NetWorkException {
      print("couldnt reach the api ${val.message}");
      return null;
    }
    return val;
  }

  Future<List<String>> downloadFilesPath(
      String userId, String configName) async {
    var filesPath;
    try {
      filesPath = await netProvider.downloadFilesPath(userId, configName);
    } on NetWorkException {
      print("couldnt reach the api ${filesPath.message}");
      return null;
    }
    return filesPath;
  }

  Future<bool> logOut(String username) async {
    bool result = false;
    try {
      result = await netProvider.logOut(username);
    } on NetWorkException {
      print("couldnt reach the api");
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
