import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../../../models/widget_node.dart';
import '../text_field.dart';
import '../section_header.dart';
import '../number_field.dart';

List<Widget> buildImagePropertyEditors(BuildContext context, WidgetNode node) {
  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
  final properties = node.properties;
  final editors = <Widget>[];

  editors.addAll([
    buildSectionHeader('Image'),
    buildTextField(
      'URL',
      properties['url'] as String? ?? 'https://picsum.photos/200',
      (value) {
        properties['url'] = (value == null) ? 'https://picsum.photos/200' : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
  ]);

  return editors;
}

List<Widget> buildCircleImagePropertyEditors(BuildContext context, WidgetNode node) {
  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
  final properties = node.properties;
  final editors = <Widget>[];

  editors.addAll([
    buildSectionHeader('Circle Image'),
    buildNumberField(
      'Radius',
      properties['radius']?.toString() ?? '20',
      (value) {
        properties['radius'] = double.tryParse(value ?? '20') ?? 20.0;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildTextField(
      'Image URL',
      properties['src'] ?? '',
      (value) {
        properties['src'] = value ?? '';
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildTextField(
      'Background Color (int)',
      properties['backgroundColor']?.toString() ?? '',
      (value) {
        properties['backgroundColor'] = int.tryParse(value ?? '');
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildTextField(
      'Foreground Color (int)',
      properties['foregroundColor']?.toString() ?? '',
      (value) {
        properties['foregroundColor'] = int.tryParse(value ?? '');
        provider.updateNodeProperties(node, properties);
      },
    ),
  ]);

  return editors;
} 