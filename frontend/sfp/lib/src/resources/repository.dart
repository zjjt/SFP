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
      users = await netProvider.fetchUsers(username, password);
    } on NetWorkException {
      print("couldnt reach the api");
      return null;
    }
    return users;
  }
}

//Custom Exceptions
class NetWorkException implements Exception {}
