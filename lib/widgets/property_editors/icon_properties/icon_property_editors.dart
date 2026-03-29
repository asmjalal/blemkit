import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../../../models/widget_node.dart';
import '../dropdown_field.dart';
import '../section_header.dart';
import '../color_picker_field.dart';
import 'package:designflutterkit/utils/color_utils.dart';


List<Widget> buildIconPropertyEditors(BuildContext context, WidgetNode node) {
  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
  final properties = node.properties;
  final editors = <Widget>[];

  editors.addAll([
    buildSectionHeader('Icon'),
    buildDropdownField(
      'Icon',
      properties['icon'] as String? ?? 'star',
      [
        'star',
        'home',
        'favorite',
        'settings',
        'search',
        'alarm',
        'person',
        'info',
        'check',
        'close',
        'menu',
        'camera',
        'phone',
        'email',
        'lock',
        'map',
        'calendar',
        'cloud',
        'delete',
        'edit',
      ],
      (value) {
        properties['icon'] = value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    ColorPickerField(
      label: 'Icon Color',
      color: ColorUtils.parseColor(properties['color'], Colors.black),
      onColorChanged: (color) {
        properties['color'] = color.value.toString();
        provider.updateNodeProperties(node, properties);
      },
    ),
  ]);

  return editors;
} 