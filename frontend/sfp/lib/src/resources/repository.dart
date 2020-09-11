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

  Future<Map<String, dynamic>> uploadFiles(List<dynamic> files,
      String configName, String userName, String extension) async {
    var fup;
    try {
      fup =
          await netProvider.uploadFiles(files, configName, userName, extension);
    } on NetWorkException {
      print("couldnt reach the api ${fup.message}");
      return null;
    }
    return fup;
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
