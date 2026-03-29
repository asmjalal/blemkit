import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../../../models/widget_node.dart';
import '../text_field.dart';
import '../section_header.dart';

List<Widget> buildBottomNavPropertyEditors(BuildContext context, WidgetNode node) {
  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
  final properties = node.properties;
  final editors = <Widget>[];

  editors.addAll([
    buildSectionHeader('Bottom Navigation Bar'),
    buildTextField(
      'Item Count',
      properties['itemCount'] as String? ?? '3',
      (value) {
        properties['itemCount'] = (value == null) ? '3' : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
  ]);

  return editors;
} 