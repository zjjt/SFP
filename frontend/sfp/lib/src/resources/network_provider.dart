import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:sfp/assets.dart';
import 'package:sfp/src/models/models.dart';
import 'package:sfp/src/resources/repository.dart';

import '../../utils.dart';

class NetworkProvider {
  String backend = Assets.backend;
  final dio = Dio();

  //fetching process configs from the backend
  Future<List<ProcessConfigModel>> fetchConfig() async {
    Utils.log('in network provider fetching configs from backend');
    var response = await dio.get('$backend/PC');
    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      List<ProcessConfigModel> configs = [];
      data.forEach((element) {
        //Utils.log(element);
        var c = ProcessConfigModel.fromJSON(element);
        configs.add(c);
      });
      return configs;
    } else {
      throw NetWorkException();
    }
  }

  Future<Map<String, dynamic>> getCurrentValidationProcess(
      String initiatorId, String configName) async {
    Utils.log(
        'in network provider trying to get the current validation process pipeline from backend for initiator $initiatorId and $configName');
    var response = await dio.get(
        '$backend/validation?configName=$configName&initiatorId=$initiatorId');
    if (response.statusCode == 200) {
      var data = response.data;
      return data;
    } else {
      throw NetWorkException();
    }
  }

  Future<Map<String, dynamic>> createUsersWithRole(
      String username,
      String userId,
      List<String> userMails,
      String role,
      String configName) async {
    Utils.log(
        'in network provider trying to create a user list as $role on the backend');
    FormData formData = FormData.fromMap({
      "username": username,
      "userId": userId,
      "usermailtocreate": userMails,
      "role": role,
      "configName": configName,
    });

    var response = await dio.post("$backend/user/createOrUpdateWithRole",
        data: formData, onSendProgress: (int sent, int total) {
      Utils.log("$sent/$total");
    });

    if (response.statusCode == 200) {
      var data = response.data;
      return data;
    } else {
      throw NetWorkException();
    }
  }

  Future<Map<String, dynamic>> fetchUsers(
      String username, String password) async {
    Utils.log(
        'in network provider trying to fetch the user from backend with $username and $password');
    var response =
        await dio.get('$backend/user/with?username=$username&tp=$password');
    if (response.statusCode == 200) {
      var data = response.data;
      return data;
    } else {
      throw NetWorkException();
    }
  }

  Future<Map<String, dynamic>> fetchCurrentProcessingFiles(
      String configName, String userId) async {
    Utils.log(
        'in network provider trying to fetch the list of the files i currently processing for uid $userId and config $configName');
    var response = await dio.get(
        '$backend/files/get-in-process?uid=$userId&configname=$configName');
    //Utils.log(response);
    if (response.statusCode == 200) {
      var data = response.data;
      return data;
    } else {
      throw NetWorkException();
    }
  }

  Future<List<String>> downloadFilesPath(
      String userId, String configName) async {
    Utils.log(
        'in network provider trying to fetch the list of the files path which processing is done for uid $userId and config $configName');
    var response = await dio.get(
        '$backend/files/generatefiles?userId=$userId&configName=$configName');
    //Utils.log(response);
    if (response.statusCode == 200) {
      var data = response.data;
      data.forEach((e) {
        e = '$backend/files/download/$e';
      });
      return data;
    } else {
      throw NetWorkException();
    }
  }

  Future<Map<String, dynamic>> deleteFilesById(
      List<ProcessedFileModel> files) async {
    List<String> fileIds = [];
    for (var f in files) {
      Utils.log("f ids: ${f.id}");
      fileIds.add(f.id);
    }
    if (fileIds.isNotEmpty) {
      FormData formData = FormData.fromMap({
        "file_ids": fileIds,
      });
      var response = await dio.post('$backend/files/delete', data: formData);
      Utils.log(response);
      if (response.statusCode == 200) {
        var data = response.data;
        return data;
      } else {
        throw NetWorkException();
      }
    } else {
      throw NetWorkException();
    }
  }

  Future<Map<String, dynamic>> uploadFiles(List<dynamic> files,
      String configName, String userId, String extension) async {
    Utils.log(
        "in network provider trying to upload ${files.length} files for config ");

    List<MultipartFile> filesM = [];
    for (var i = 0; i < files.length; i++) {
      if (files[i] is File) {
        filesM.add(MultipartFile.fromBytes(files[i].readAsBytesSync(),
            filename: "fichier${configName}_$i.$extension",
            contentType: MediaType.parse("multipart/form-data")));
      } else {
        filesM.add(MultipartFile.fromBytes(
            await Utils.convertHtmlFileToBytes(files[i]),
            filename: "fichier${configName}_$i.$extension",
            contentType: MediaType.parse("multipart/form-data")));
      }
    }
    Utils.log('files to upload  ${filesM.length}');
    var response;
    if (filesM.isNotEmpty) {
      FormData formData = FormData.fromMap({
        "files": filesM,
        "configName": configName,
        "userId": userId,
      });

      Utils.log('files to upload  ${formData.files.length}');

      response = await dio.post("$backend/files/upload", data: formData,
          onSendProgress: (int sent, int total) {
        Utils.log("$sent/$total");
      });
    }
    if (response.statusCode == 200) {
      var data = response.data;
      return data;
    } else {
      throw NetWorkException();
    }
  }

  Future<bool> logOut(String username) async {
    Utils.log('in network provider logging out the user');
    var response =
        await dio.get('${Assets.backend}/user/logout?username=$username');
    if (response.statusCode == 200) {
      var data = response.data;
      Utils.log("data logout $data");
      Utils.log(data is bool);
      return true;
    } else {
      throw NetWorkException();
    }
  }
}

var netProvider = NetworkProvider();
