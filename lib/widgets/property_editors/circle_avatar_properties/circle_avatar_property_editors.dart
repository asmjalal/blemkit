import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../../../models/widget_node.dart';
import '../text_field.dart';
import '../section_header.dart';
import '../number_field.dart';
import '../color_picker_field.dart';
import '../../../utils/color_utils.dart';

List<Widget> buildCircleAvatarPropertyEditors(BuildContext context, WidgetNode node) {
  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
  final properties = node.properties;
  final editors = <Widget>[];

  editors.addAll([
    buildSectionHeader('Circle Avatar'),
    buildNumberField(
      'Radius',
      properties['radius']?.toString() ?? '20',
      (value) {
        properties['radius'] = double.tryParse(value ?? '20') ?? 20.0;
        provider.updateNodeProperties(node, properties);
      },
    ),
    ColorPickerField(
      label: 'Background Color',
      color: ColorUtils.parseColor(properties['backgroundColor'], Colors.blue),
      onColorChanged: (color) {
        properties['backgroundColor'] = color.value.toString();
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildTextField(
      'Background Image URL',
      properties['backgroundImage'] ?? '',
      (value) {
        properties['backgroundImage'] = value ?? '';
        provider.updateNodeProperties(node, properties);
      },
    ),
  ]);

  return editors;
}
