import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../../../models/widget_node.dart';

import '../text_field.dart';
import '../section_header.dart';
import '../color_picker_field.dart';
import '../slider_field.dart';
import '../dropdown_field.dart';
import '../number_field.dart';
import '../edge_insets_editor.dart';
import 'package:designflutterkit/utils/color_utils.dart';

List<Widget> buildTextFieldPropertyEditors(BuildContext context, WidgetNode node) {
  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
  final properties = node.properties;
  final editors = <Widget>[];

  String _safeValue(dynamic val, String fallback) {
    if (val == null || val is! String) return fallback;
    return val.contains('.') ? val.split('.').last : val;
  }

  editors.addAll([
    buildSectionHeader('Text Field Properties'),
    buildTextField(
      'Initial Value',
      properties['initialValue'] as String? ?? '',
      (value) {
        properties['initialValue'] = value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildTextField(
      'Label Text',
      properties['labelText'] as String? ?? '',
      (value) {
        properties['labelText'] = value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildTextField(
      'Hint Text',
      properties['hintText'] as String? ?? '',
      (value) {
        properties['hintText'] = value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSliderField(
      'Font Size',
      (properties['fontSize'] is num && properties['fontSize'] != null) ? properties['fontSize'].toDouble() : 14.0,
      8.0,
      64.0,
      (value) {
        properties['fontSize'] = (value == null || value.isNaN) ? 14.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildDropdownField(
      'Font Weight',
      _safeValue(properties['fontWeight'], 'normal'),
      ['normal', 'bold', 'w100', 'w200', 'w300', 'w400', 'w500', 'w600', 'w700', 'w800', 'w900'],
      (value) {
        properties['fontWeight'] = value ?? 'normal';
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildDropdownField(
      'Text Align',
      _safeValue(properties['textAlign'], 'start'),
      ['start', 'left', 'center', 'right', 'justify', 'end'],
      (value) {
        properties['textAlign'] = value ?? 'start';
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSectionHeader('Style'),
    ColorPickerField(
      label: 'Fill Color',
      color: ColorUtils.parseColor(properties['fillColor'], Colors.transparent),
      onColorChanged: (color) {
        properties['fillColor'] = color.value.toString();
        provider.updateNodeProperties(node, properties);
      },
    ),
    ColorPickerField(
      label: 'Border Color',
      color: ColorUtils.parseColor(properties['borderColor'], Colors.black),
      onColorChanged: (color) {
        properties['borderColor'] = color.value.toString();
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSliderField(
      'Border Width',
      (properties['borderWidth'] is num && properties['borderWidth'] != null) ? properties['borderWidth'].toDouble() : 1.0,
      0.0,
      12.0,
      (value) {
        properties['borderWidth'] = (value == null || value.isNaN) ? 1.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSliderField(
      'Border Radius',
      (properties['borderRadius'] is num && properties['borderRadius'] != null) ? properties['borderRadius'].toDouble() : 8.0,
      0.0,
      64.0,
      (value) {
        properties['borderRadius'] = (value == null || value.isNaN) ? 8.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    ColorPickerField(
      label: 'Text Color',
      color: ColorUtils.parseColor(properties['textColor'], Colors.white),
      onColorChanged: (color) {
        properties['textColor'] = color.value.toString();
        provider.updateNodeProperties(node, properties);
      },
    ),
    // Input Decoration Properties
    buildSectionHeader('Input Decoration Properties'),
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Input Border Type',
          border: OutlineInputBorder(),
        ),
        value: properties['inputBorderType'] as String? ?? 'Outline',
        items: ['Outline', 'Underline', 'None'].map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            properties['inputBorderType'] = value;
            provider.updateNodeProperties(node, properties);
          }
        },
      ),
    ),
    SwitchListTile(
      title: const Text('Filled'),
      value: properties['filled'] == true,
      onChanged: (value) {
        properties['filled'] = value;
        provider.updateNodeProperties(node, properties);
      },
      contentPadding: EdgeInsets.zero,
    ),
    ColorPickerField(
      label: 'Fill Color',
      color: ColorUtils.parseColor(properties['inputFillColor'], Colors.transparent),
      onColorChanged: (color) {
        properties['inputFillColor'] = color.value.toString();
        provider.updateNodeProperties(node, properties);
      },
    ),
    ColorPickerField(
      label: 'Border Color',
      color: ColorUtils.parseColor(properties['inputBorderColor'], Colors.black),
      onColorChanged: (color) {
        properties['inputBorderColor'] = color.value.toString();
        provider.updateNodeProperties(node, properties);
      },
    ),
    ColorPickerField(
      label: 'Focus Border Color',
      color: ColorUtils.parseColor(properties['focusBorderColor'], Colors.blue),
      onColorChanged: (color) {
        properties['focusBorderColor'] = color.value.toString();
        provider.updateNodeProperties(node, properties);
      },
    ),
    ColorPickerField(
      label: 'Error Border Color',
      color: ColorUtils.parseColor(properties['errorBorderColor'], Colors.red),
      onColorChanged: (color) {
        properties['errorBorderColor'] = color.value.toString();
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSliderField(
      'Border Width',
      (properties['inputBorderWidth'] is num && properties['inputBorderWidth'] != null) ? properties['inputBorderWidth'].toDouble() : 1.0,
      0.0,
      12.0,
      (value) {
        properties['inputBorderWidth'] = (value == null || value.isNaN) ? 1.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSliderField(
      'Border Radius',
      (properties['inputBorderRadius'] is num && properties['inputBorderRadius'] != null) ? properties['inputBorderRadius'].toDouble() : 8.0,
      0.0,
      64.0,
      (value) {
        properties['inputBorderRadius'] = (value == null || value.isNaN) ? 8.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    ColorPickerField(
      label: 'Hover Color',
      color: ColorUtils.parseColor(properties['hoverColor'], Colors.grey),
      onColorChanged: (color) {
        properties['hoverColor'] = color.value.toString();
        provider.updateNodeProperties(node, properties);
      },
    ),
    // Content Padding (EdgeInsets)
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text('Content Padding', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
    ),
    EdgeInsetsEditor(
      label: 'Content Padding',
      top: (properties['contentPaddingTop'] ?? 0.0).toDouble(),
      bottom: (properties['contentPaddingBottom'] ?? 0.0).toDouble(),
      left: (properties['contentPaddingLeft'] ?? 0.0).toDouble(),
      right: (properties['contentPaddingRight'] ?? 0.0).toDouble(),
      onChanged: (vals) {
        properties['contentPaddingTop'] = vals['top'] ?? 0.0;
        properties['contentPaddingBottom'] = vals['bottom'] ?? 0.0;
        properties['contentPaddingLeft'] = vals['left'] ?? 0.0;
        properties['contentPaddingRight'] = vals['right'] ?? 0.0;
        provider.updateNodeProperties(node, properties);
      },
    ),
  ]);

  return editors;
} 