import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sfp/src/models/models.dart';

class Repository {
  Future<ProcessConfigModel> fetchConfig() async {
    List<ProcessConfigModel> configs;
    try {
      //here we call our api via the network provider
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        configs = null;
      }
    } on SocketException catch (e) {
      Fluttertoast.showToast(
          msg: "Aucune connexion internet détectée",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey,
          textColor: Colors.black,
          fontSize: 12.0);
      print('no internet connetion $e');
    }
  }
}
