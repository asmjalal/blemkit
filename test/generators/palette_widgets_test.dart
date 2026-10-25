import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:designflutterkit/generators/project_generator.dart';
import 'package:designflutterkit/generators/widget_generator_registry.dart';
import 'package:designflutterkit/models/widget_node.dart';
import 'package:designflutterkit/widgets/canvas_preview/builders/widget_builder_factory.dart';
import 'package:designflutterkit/widgets/widget_sidebar/widget_side_bar.dart';
import 'package:designflutterkit/widgets/widget_tree/widget_tree_editor.dart';

/// Every palette entry must have a canvas builder and a code generator,
/// and the "kitchen sink" export of all of them must compile
/// (checked by `tool/check_export.sh`).
void main() {
  final types = WidgetSidebar.paletteTypes;

  test('every palette type can be created, previewed and generated', () {
    WidgetBuilderFactory.initialize();
    final missing = <String>[];
    for (final type in types) {
      final node = WidgetTreeEditor.createWidgetNodeWithDefaults(type);
      if (!WidgetGeneratorRegistry.hasGenerator(node.type)) missing.add('$type (no generator for ${node.type})');
      if (!WidgetBuilderFactory.hasBuilder(node.type)) missing.add('$type (no canvas builder for ${node.type})');
    }
    expect(missing, isEmpty);
  });

  test('kitchen sink export', () {
    final children = <WidgetNode>[];
    for (final type in types) {
      if (const {'Scaffold', 'AppBar', 'Drawer', 'EndDrawer', 'BottomNavigationBar', 'FAB', 'SnackBar', 'BottomSheet', 'AlertDialog', 'Dialog', 'Expanded', 'Flexible', 'Spacer', 'Positioned'}.contains(type)) {
        continue;
      }
      children.add(WidgetTreeEditor.createWidgetNodeWithDefaults(type));
    }
    final screen = WidgetNode(type: 'Scaffold', properties: {'pageName': 'Kitchen Sink'}, children: [
      WidgetNode(type: 'SingleChildScrollView', children: [
        WidgetNode(type: 'Column', children: children),
      ]),
    ]);
    final files = ProjectGenerator.generateFullProject([screen], {}, []);
    final exportDir = Platform.environment['EXPORT_DIR'];
    if (exportDir != null) {
      files.forEach((path, content) {
        final out = File('$exportDir/kitchen_sink/$path');
        out.parent.createSync(recursive: true);
        out.writeAsStringSync(content);
      });
    }
    expect(files['lib/kitchen_sink_screen.dart'], isNotNull);
  });
}
