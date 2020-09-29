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
    print('in network provider fetching configs from backend');
    var response = await dio.get('$backend/PC');
    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      List<ProcessConfigModel> configs = [];
      data.forEach((element) {
        //print(element);
        var c = ProcessConfigModel.fromJSON(element);
        configs.add(c);
      });
      return configs;
    } else {
      throw NetWorkException();
    }
  }

  Future<Map<String, dynamic>> fetchUsers(
      String username, String password) async {
    print(
        'in network provider trying to fetch the user from backend with $username and $password');
    var response =
        await dio.get('$backend/user/with?username=$username&tp=$password');
    print(response);
    if (response.statusCode == 200) {
      var data = response.data;
      return data;
    } else {
      throw NetWorkException();
    }
  }

  Future<Map<String, dynamic>> fetchCurrentProcessingFiles(
      String configName, String userId) async {
    print(
        'in network provider trying to fetch the list of the files i currently processing for uid $userId and config $configName');
    var response = await dio.get(
        '$backend/files/get-in-process?uid=$userId&configname=$configName');
    //print(response);
    if (response.statusCode == 200) {
      var data = response.data;
      return data;
    } else {
      throw NetWorkException();
    }
  }

  Future<Map<String, dynamic>> deleteFilesById(
      List<ProcessedFileModel> files) async {
    List<String> fileIds = [];
    for (var f in files) {
      print("f ids: ${f.id}");
      fileIds.add(f.id);
    }
    if (fileIds.isNotEmpty) {
      FormData formData = FormData.fromMap({
        "file_ids": fileIds,
      });
      var response = await dio.post('$backend/files/delete', data: formData);
      print(response);
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
    print(
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
    print('files to upload  ${filesM.length}');
    var response;
    if (filesM.isNotEmpty) {
      FormData formData = FormData.fromMap({
        "files": filesM,
        "configName": configName,
        "userId": userId,
      });

      print('files to upload  ${formData.files.length}');

      response = await dio.post("$backend/files/upload", data: formData,
          onSendProgress: (int sent, int total) {
        print("$sent/$total");
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
    print('in network provider logging out the user');
    var response =
        await dio.get('${Assets.backend}/user/logout?username=$username');
    if (response.statusCode == 200) {
      var data = response.data;
      print("data logout $data");
      print(data is bool);
      return true;
    } else {
      throw NetWorkException();
    }
  }
}

var netProvider = NetworkProvider();
