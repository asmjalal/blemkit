import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../../../models/widget_node.dart';
import '../text_field.dart';
import '../section_header.dart';
import '../color_picker_field.dart';
import 'package:designflutterkit/utils/color_utils.dart';


List<Widget> buildGridPropertyEditors(BuildContext context, WidgetNode node) {
  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
  final properties = node.properties;
  final editors = <Widget>[];

  editors.addAll([
    buildSectionHeader('Grid View'),
    buildTextField(
      'Cross Axis Count',
      properties['crossAxisCount']?.toString() ?? '2',
      (value) {
        if (value != null && value.isNotEmpty) {
          final count = int.tryParse(value);
          if (count != null && count > 0) {
            properties['crossAxisCount'] = count;
            provider.updateNodeProperties(node, properties);
          }
        }
      },
    ),
    buildTextField(
      'Cross Axis Spacing',
      properties['crossAxisSpacing']?.toString() ?? '0',
      (value) {
        if (value != null && value.isNotEmpty) {
          final spacing = double.tryParse(value);
          if (spacing != null && spacing >= 0) {
            properties['crossAxisSpacing'] = spacing;
            provider.updateNodeProperties(node, properties);
          }
        }
      },
    ),
    buildTextField(
      'Main Axis Spacing',
      properties['mainAxisSpacing']?.toString() ?? '0',
      (value) {
        if (value != null && value.isNotEmpty) {
          final spacing = double.tryParse(value);
          if (spacing != null && spacing >= 0) {
            properties['mainAxisSpacing'] = spacing;
            provider.updateNodeProperties(node, properties);
          }
        }
      },
    ),
    buildTextField(
      'Child Aspect Ratio',
      properties['childAspectRatio']?.toString() ?? '1.0',
      (value) {
        if (value != null && value.isNotEmpty) {
          final ratio = double.tryParse(value);
          if (ratio != null && ratio > 0) {
            properties['childAspectRatio'] = ratio;
            provider.updateNodeProperties(node, properties);
          }
        }
      },
    ),
    ColorPickerField(
      label: 'Background Color',
      color: ColorUtils.parseColor(properties['backgroundColor'], Colors.transparent),
      onColorChanged: (color) {
        properties['backgroundColor'] = color.value.toString();
        provider.updateNodeProperties(node, properties);
      },
    ),
  ]);

  return editors;
} 