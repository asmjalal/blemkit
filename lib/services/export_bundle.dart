import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';

/// Turns generated project files into a complete Flutter project: the native
/// folders from `assets/base_template.zip` (renamed to the app and bundle id)
/// plus the generated `lib/`, `pubspec.yaml` and friends.
class ExportBundle {
  static const _textExtensions = {'xml', 'kt', 'java', 'gradle', 'kts', 'swift', 'pbxproj', 'plist', 'h', 'm', 'sh', 'xcconfig', 'json', 'md', 'yaml', 'html', 'storyboard', 'xib'};

  /// Path → bytes for every file of the exported project.
  static Future<Map<String, List<int>>> build(Map<String, String> generated, String appName, String bundleName) async {
    final baseBytes = await rootBundle.load('assets/base_template.zip');
    final baseArchive = ZipDecoder().decodeBytes(baseBytes.buffer.asUint8List());
    final safeAppName = appName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]+'), '_');
    final out = <String, List<int>>{};

    for (final file in baseArchive) {
      if (!file.isFile) continue;
      final name = file.name;
      // Generated paths come from the generator instead.
      if (name.startsWith('lib/') || name.startsWith('test/') || const {'pubspec.yaml', 'README.md', 'analysis_options.yaml', '.gitignore', 'pubspec.lock'}.contains(name)) {
        continue;
      }
      final path = name.replaceAll('com/example/base_template', bundleName.replaceAll('.', '/')).replaceAll('base_template', safeAppName);
      var bytes = file.content as List<int>;
      if (_textExtensions.contains(name.split('.').last)) {
        try {
          var text = utf8.decode(bytes);
          text = text.replaceAll('com.example.base_template', bundleName).replaceAll('base_template', safeAppName);
          // User-facing app name on Android and iOS.
          text = text
              .replaceAll('android:label="$safeAppName"', 'android:label="$appName"')
              .replaceAll('<string>$safeAppName</string>', '<string>$appName</string>');
          bytes = utf8.encode(text);
        } catch (_) {
          // Leave files that are not UTF-8 untouched.
        }
      }
      out[path] = bytes;
    }

    generated.forEach((path, content) => out[path] = utf8.encode(content));
    return out;
  }

  static List<int>? zip(Map<String, List<int>> files) {
    final archive = Archive();
    files.forEach((path, bytes) => archive.addFile(ArchiveFile(path, bytes.length, bytes)));
    return ZipEncoder().encode(archive);
  }
}
