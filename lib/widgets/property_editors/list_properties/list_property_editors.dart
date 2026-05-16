import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../../../models/widget_node.dart';
import '../text_field.dart';
import '../section_header.dart';
import '../color_picker_field.dart';
import 'package:designflutterkit/utils/color_utils.dart';


import '../dropdown_field.dart';

List<Widget> buildListPropertyEditors(BuildContext context, WidgetNode node) {
  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
  final properties = node.properties;
  final editors = <Widget>[];

  editors.addAll([
    buildSectionHeader('List View'),
    buildTextField(
      'Item Count',
      properties['itemCount'] as String? ?? '5',
      (value) {
        properties['itemCount'] = (value == null) ? '5' : value;
        provider.updateNodeProperties(node, properties);
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

String _safeString(dynamic value) {
  if (value is String) return value;
  if (value is Map && value['properties'] is Map) {
    return value['properties']['text']?.toString() ?? value['properties']['label']?.toString() ?? '';
  }
  return value?.toString() ?? '';
}

List<Widget> buildListTilePropertyEditors(BuildContext context, WidgetNode node) {
  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
  final properties = node.properties;
  final editors = <Widget>[];

  editors.addAll([
    buildSectionHeader('ListTile'),
    buildTextField(
      'Title',
      _safeString(properties['title']),
      (value) {
        properties['title'] = value ?? '';
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildTextField(
      'Subtitle',
      _safeString(properties['subtitle']),
      (value) {
        properties['subtitle'] = value ?? '';
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildTextField(
      'Leading Icon (name)',
      _safeString(properties['leadingIcon']),
      (value) {
        properties['leadingIcon'] = value ?? '';
        provider.updateNodeProperties(node, properties);
      },
    ),
    ColorPickerField(
      label: 'Leading Icon Color',
      color: properties['leadingIconColor'] != null ? Color(properties['leadingIconColor']) : Colors.black,
      onColorChanged: (color) {
        properties['leadingIconColor'] = color.value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildTextField(
      'Trailing Icon (name)',
      _safeString(properties['trailingIcon']),
      (value) {
        properties['trailingIcon'] = value ?? '';
        provider.updateNodeProperties(node, properties);
      },
    ),
    ColorPickerField(
      label: 'Trailing Icon Color',
      color: properties['trailingIconColor'] != null ? Color(properties['trailingIconColor']) : Colors.black,
      onColorChanged: (color) {
        properties['trailingIconColor'] = color.value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    Row(
      children: [
        Checkbox(
          value: properties['enabled'] ?? true,
          onChanged: (value) {
            properties['enabled'] = value ?? true;
            provider.updateNodeProperties(node, properties);
          },
        ),
        const Text('Enabled'),
      ],
    ),
    const SizedBox(height: 12),
    buildSectionHeader('Navigation'),
    buildDropdownField(
      'Navigate To',
      provider.screens.any((s) => s.id == properties['navigateTo'])
          ? provider.screens.firstWhere((s) => s.id == properties['navigateTo']).properties['pageName'] as String? ?? 'Page'
          : 'None',
      ['None', ...provider.screens.map((s) => s.properties['pageName'] as String? ?? 'Page')],
      (value) {
        if (value == 'None' || value == null) {
          properties['navigateTo'] = null;
        } else {
          try {
            final target = provider.screens.firstWhere((s) => s.properties['pageName'] == value);
            properties['navigateTo'] = target.id;
          } catch (e) {
            properties['navigateTo'] = null;
          }
        }
        provider.updateNodeProperties(node, properties);
      },
    ),
  ]);

  return editors;
} 