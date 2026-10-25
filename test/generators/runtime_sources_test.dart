import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:designflutterkit/generators/runtime_sources.g.dart';

void main() {
  test('embedded runtime sources match lib/runtime/exported (run dart run tool/embed_runtime.dart)', () {
    final files = Directory('lib/runtime/exported').listSync().whereType<File>().where((f) => f.path.endsWith('.dart'));
    for (final file in files) {
      expect(kRuntimeSources[file.uri.pathSegments.last], file.readAsStringSync(), reason: file.path);
    }
    expect(kRuntimeSources.length, files.length);
  });
}
