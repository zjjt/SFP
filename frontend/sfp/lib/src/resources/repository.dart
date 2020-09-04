import 'package:sfp/src/models/models.dart';
import 'package:sfp/src/resources/resources.dart';

class Repository {
  Future<List<ProcessConfigModel>> fetchConfig() async {
    List<ProcessConfigModel> configs;
    try {
      configs = await netProvider.fetchConfig();
    } on NetWorkException {
      print("couldnt reach the api");
    }
    //print(configs);
    return configs;
  }
}

//Custom Exceptions
class NetWorkException implements Exception {}
