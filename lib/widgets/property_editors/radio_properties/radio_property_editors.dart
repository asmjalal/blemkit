import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../../../models/widget_node.dart';
import '../text_field.dart';
import '../section_header.dart';

List<Widget> buildRadioPropertyEditors(BuildContext context, WidgetNode node) {
  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
  final properties = node.properties;
  final editors = <Widget>[];

  editors.addAll([
    buildSectionHeader('Radio'),
    buildTextField(
      'Label',
      properties['label'] as String? ?? 'Radio',
      (value) {
        properties['label'] = (value == null) ? 'Radio' : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
  ]);

  return editors;
} 