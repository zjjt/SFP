import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:sfp/src/app.dart';

void main() async {
  await FlutterConfig.loadEnvVariables();
  runApp(App());
}
