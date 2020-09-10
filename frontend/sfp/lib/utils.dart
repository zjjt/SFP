import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

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
}
