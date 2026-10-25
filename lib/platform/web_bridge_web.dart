import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

class WebBridge {
  static String? read(String key) => web.window.localStorage.getItem(key);

  static void write(String key, String value) => web.window.localStorage.setItem(key, value);

  static void remove(String key) => web.window.localStorage.removeItem(key);

  static bool downloadBytes(List<int> bytes, String fileName) {
    final blob = web.Blob([Uint8List.fromList(bytes).toJS].toJS);
    final url = web.URL.createObjectURL(blob);
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = fileName;
    anchor.click();
    web.URL.revokeObjectURL(url);
    return true;
  }

  static void suppressContextMenu() {
    web.document.addEventListener(
      'contextmenu',
      ((web.Event event) => event.preventDefault()).toJS,
    );
  }
}
