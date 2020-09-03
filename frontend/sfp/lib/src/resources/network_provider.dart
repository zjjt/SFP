import 'package:flutter_config/flutter_config.dart';
import 'package:http/http.dart' show Client;
import 'package:sfp/src/models/models.dart';

class NetworkProvider {
  Client http = Client();
  String backend = FlutterConfig.get("API_URL");
  //fetching process configs from the backend
  Future<ProcessConfigModel> fetchConfig() async {
    print('in network provider fetching configs from backend');
  }
}
