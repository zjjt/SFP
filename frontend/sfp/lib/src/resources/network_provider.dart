import 'dart:convert';

import 'package:http/http.dart' show Client;
import 'package:sfp/assets.dart';
import 'package:sfp/src/models/models.dart';
import 'package:sfp/src/resources/repository.dart';

class NetworkProvider {
  Client client = Client();
  String backend = Assets.backend;
  //fetching process configs from the backend
  Future<List<ProcessConfigModel>> fetchConfig() async {
    print('in network provider fetching configs from backend');
    var response = await client.get('${Assets.backend}/PC');
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
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
}

var netProvider = NetworkProvider();
