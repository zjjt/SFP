import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:sfp/assets.dart';
import 'package:universal_html/html.dart' as html;

class Utils {
  static Future<Uint8List> convertHtmlFileToBytes(html.File hf) async {
    Uint8List _bytes;
    Completer<Uint8List> _bytesCompleter = Completer<Uint8List>();
    var reader = html.FileReader();
    reader.onLoadEnd.listen((event) {
      _bytes =
          Base64Decoder().convert(reader.result.toString().split(",").last);
      _bytesCompleter.complete(_bytes);
    });
    reader.readAsDataUrl(hf);
    return _bytesCompleter.future;
  }

  static Uint8List convertByteToUint8List(String source) {
    var list = List<int>();
    source.runes.forEach((rune) {
      if (rune >= 0x10000) {
        rune -= 0x10000;
        int firstWord = (rune >> 10) + 0xD800;
        list.add(firstWord >> 8);
        list.add(firstWord & 0xFF);
        int secondWord = (rune & 0x3FF) + 0xDC00;
        list.add(secondWord >> 8);
        list.add(secondWord & 0xFF);
      } else {
        list.add(rune >> 8);
        list.add(rune & 0xFF);
      }
    });
    Uint8List bytes = Uint8List.fromList(list);
    return bytes;
  }

  static void log(dynamic s) {
    if (Assets.env == "dev") {
      print(s.toString());
    }
  }

  static bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }
}
