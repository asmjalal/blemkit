import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../../../models/widget_node.dart';
import '../text_field.dart';
import '../section_header.dart';
import '../color_picker_field.dart';
import 'package:designflutterkit/utils/color_utils.dart';


List<Widget> buildCardPropertyEditors(BuildContext context, WidgetNode node) {
  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
  final properties = node.properties;
  final editors = <Widget>[];

  editors.addAll([
    buildSectionHeader('Card'),
    buildTextField(
      'Title',
      properties['title'] as String? ?? 'Card Title',
      (value) {
        properties['title'] = (value == null) ? 'Card Title' : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    ColorPickerField(
      label: 'Background Color',
      color: ColorUtils.parseColor(properties['color'], Colors.white),
      onColorChanged: (color) {
        properties['color'] = color.value.toString();
        provider.updateNodeProperties(node, properties);
      },
    ),
  ]);

  return editors;
} 