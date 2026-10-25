import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:designflutterkit/generators/project_generator.dart';
import 'package:designflutterkit/models/widget_node.dart';

/// Generates a full project for every bundled template.
///
/// Set EXPORT_DIR to also write the generated files to disk so that
/// `tool/check_export.sh` can run `flutter analyze` on them.
void main() {
  final exportDir = Platform.environment['EXPORT_DIR'];
  final templateFiles = Directory('lib/templates')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in templateFiles) {
    final name = file.uri.pathSegments.last.replaceAll('.json', '');
    test('exports template $name', () {
      final decoded = jsonDecode(file.readAsStringSync());
      final screens = decoded is List
          ? decoded.map((s) => WidgetNode.fromJson(Map<String, dynamic>.from(s as Map))).toList()
          : [WidgetNode.fromJson(Map<String, dynamic>.from(decoded as Map))];

      final files = ProjectGenerator.generateFullProject(screens, {}, []);

      expect(files['lib/main.dart'], isNotNull);
      expect(files['pubspec.yaml'], isNotNull);
      for (final entry in files.entries) {
        expect(entry.value, isNot(contains('// Unknown widget type')), reason: '${entry.key} has an unknown widget');
      }

      if (exportDir != null) {
        files.forEach((path, content) {
          final out = File('$exportDir/$name/$path');
          out.parent.createSync(recursive: true);
          out.writeAsStringSync(content);
        });
      }
    });
  }
}
