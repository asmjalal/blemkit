import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../../../models/widget_node.dart';
import '../slider_field.dart';
import '../dropdown_field.dart';
import '../color_picker_field.dart';
import '../text_field.dart';
import '../section_header.dart';
import '../edge_insets_editor.dart';
import 'package:designflutterkit/utils/color_utils.dart';


import '../numeric_property_field.dart';

List<Widget> buildTextPropertyEditors(BuildContext context, WidgetNode node) {
  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
  final properties = node.properties;
  final editors = <Widget>[];

  String _safeValue(dynamic val, String fallback) {
    if (val == null || val is! String) return fallback;
    return val.contains('.') ? val.split('.').last : val;
  }

  editors.addAll([
    buildSectionHeader('Text Content'),
    buildTextField(
      'Text',
      properties['text'] as String? ?? 'Text',
      (value) {
        properties['text'] = (value == null) ? 'Text' : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    const SizedBox(height: 12),
    buildSectionHeader('Typography'),
    buildPropertyRow([
      buildNumericPropertyField(
        label: 'Size',
        value: (properties['fontSize'] ?? 14.0).toStringAsFixed(0),
        onChanged: (value) {
          properties['fontSize'] = double.tryParse(value) ?? 14.0;
          provider.updateNodeProperties(node, properties);
        },
      ),
      buildDropdownField(
        'Weight',
        _safeValue(properties['fontWeight'], 'normal'),
        ['normal', 'bold', 'w100', 'w200', 'w300', 'w400', 'w500', 'w600', 'w700', 'w800', 'w900'],
        (value) {
          properties['fontWeight'] = value ?? 'normal';
          provider.updateNodeProperties(node, properties);
        },
      ),
    ]),
    buildPropertyRow([
      buildDropdownField(
        'Style',
        _safeValue(properties['fontStyle'], 'normal'),
        ['normal', 'italic'],
        (value) {
          properties['fontStyle'] = value ?? 'normal';
          provider.updateNodeProperties(node, properties);
        },
      ),
      buildDropdownField(
        'Family',
        _safeValue(properties['fontFamily'], 'Roboto'),
        ['Roboto', 'Arial', 'Times New Roman', 'Courier', 'Verdana', 'Georgia', 'Monospace'],
        (value) {
          properties['fontFamily'] = value ?? 'Roboto';
          provider.updateNodeProperties(node, properties);
        },
      ),
    ]),
    buildPropertyRow([
      buildSliderField(
        'Letter',
        (properties['letterSpacing'] is num && properties['letterSpacing'] != null) ? properties['letterSpacing'].toDouble() : 0.0,
        0.0,
        10.0,
        (value) {
          properties['letterSpacing'] = (value == null || value.isNaN) ? 0.0 : value;
          provider.updateNodeProperties(node, properties);
        },
      ),
      buildSliderField(
        'Word',
        (properties['wordSpacing'] is num && properties['wordSpacing'] != null) ? properties['wordSpacing'].toDouble() : 0.0,
        0.0,
        20.0,
        (value) {
          properties['wordSpacing'] = (value == null || value.isNaN) ? 0.0 : value;
          provider.updateNodeProperties(node, properties);
        },
      ),
    ]),
    buildPropertyRow([
      buildSliderField(
        'Height',
        (properties['lineHeight'] is num && properties['lineHeight'] != null) ? properties['lineHeight'].toDouble() : 1.0,
        0.5,
        3.0,
        (value) {
          properties['lineHeight'] = (value == null || value.isNaN) ? 1.0 : value;
          provider.updateNodeProperties(node, properties);
        },
      ),
      buildSliderField(
        'Lines',
        (properties['maxLines'] is num && properties['maxLines'] != null) ? properties['maxLines'].toDouble() : 1.0,
        1.0,
        10.0,
        (value) {
          properties['maxLines'] = (value == null || value.isNaN) ? 1.0 : value;
          provider.updateNodeProperties(node, properties);
        },
      ),
    ]),
    buildPropertyRow([
      buildDropdownField(
        'Align',
        _safeValue(properties['textAlign'], 'start'),
        ['start', 'left', 'center', 'right', 'justify', 'end'],
        (value) {
          properties['textAlign'] = value ?? 'start';
          provider.updateNodeProperties(node, properties);
        },
      ),
      buildDropdownField(
        'Decor',
        _safeValue(properties['textDecoration'], 'none'),
        ['none', 'underline', 'lineThrough', 'overline'],
        (value) {
          properties['textDecoration'] = value ?? 'none';
          provider.updateNodeProperties(node, properties);
        },
      ),
    ]),
    buildPropertyRow([
      buildDropdownField(
        'Overflow',
        _safeValue(properties['overflow'], 'clip'),
        ['clip', 'ellipsis', 'fade', 'visible'],
        (value) {
          properties['overflow'] = value ?? 'clip';
          provider.updateNodeProperties(node, properties);
        },
      ),
      buildDropdownField(
        'Direction',
        _safeValue(properties['textDirection'], 'ltr'),
        ['ltr', 'rtl'],
        (value) {
          properties['textDirection'] = value ?? 'ltr';
          provider.updateNodeProperties(node, properties);
        },
      ),
    ]),
    buildSliderField(
      'Max Lines',
      (properties['maxLines'] is num && properties['maxLines'] != null) ? properties['maxLines'].toDouble() : 1.0,
      1.0,
      10.0,
      (value) {
        properties['maxLines'] = (value == null || value.isNaN) ? 1.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildDropdownField(
      'Overflow',
      _safeValue(properties['overflow'], 'clip'),
      ['clip', 'ellipsis', 'fade', 'visible'],
      (value) {
        properties['overflow'] = value ?? 'clip';
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildDropdownField(
      'Text Direction',
      _safeValue(properties['textDirection'], 'ltr'),
      ['ltr', 'rtl'],
      (value) {
        properties['textDirection'] = value ?? 'ltr';
        provider.updateNodeProperties(node, properties);
      },
    ),
    SwitchListTile(
      title: const Text('Soft Wrap'),
      value: properties['softWrap'] == true,
      onChanged: (value) {
        properties['softWrap'] = (value == null) ? false : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSectionHeader('Appearance'),
    buildPropertyRow([
      ColorPickerField(
        label: 'Color',
        color: ColorUtils.parseColor(properties['color'], Colors.black),
        onColorChanged: (color) {
          properties['color'] = color.value.toString();
          provider.updateNodeProperties(node, properties);
        },
      ),
      SwitchListTile(
        title: const Text('Wrap', style: TextStyle(color: Colors.white70, fontSize: 11)),
        value: properties['softWrap'] == true,
        onChanged: (value) {
          properties['softWrap'] = (value == null) ? false : value;
          provider.updateNodeProperties(node, properties);
        },
      ),
    ]),
    buildSectionHeader('Shadow'),
    buildPropertyRow([
      ColorPickerField(
        label: 'Color',
        color: ColorUtils.parseColor(properties['shadowColor'], Colors.black26),
        onColorChanged: (color) {
          properties['shadowColor'] = color.value.toString();
          provider.updateNodeProperties(node, properties);
        },
      ),
      buildSliderField(
        'Blur',
        (properties['shadowBlur'] is num && properties['shadowBlur'] != null) ? properties['shadowBlur'].toDouble() : 0.0,
        0.0,
        32.0,
        (value) {
          properties['shadowBlur'] = (value == null || value.isNaN) ? 0.0 : value;
          provider.updateNodeProperties(node, properties);
        },
      ),
    ]),
    buildPropertyRow([
      buildSliderField(
        'X Offset',
        (properties['shadowX'] is num && properties['shadowX'] != null) ? properties['shadowX'].toDouble() : 0.0,
        -32.0,
        32.0,
        (value) {
          properties['shadowX'] = (value == null || value.isNaN) ? 0.0 : value;
          provider.updateNodeProperties(node, properties);
        },
      ),
      buildSliderField(
        'Y Offset',
        (properties['shadowY'] is num && properties['shadowY'] != null) ? properties['shadowY'].toDouble() : 0.0,
        -32.0,
        32.0,
        (value) {
          properties['shadowY'] = (value == null || value.isNaN) ? 0.0 : value;
          provider.updateNodeProperties(node, properties);
        },
      ),
    ]),
    // Padding and Margin editors for Text widget
    buildSectionHeader('Padding'),
    EdgeInsetsEditor(
      label: 'Padding',
      top: (properties['paddingTop'] is num) ? properties['paddingTop'].toDouble() : 0.0,
      right: (properties['paddingRight'] is num) ? properties['paddingRight'].toDouble() : 0.0,
      bottom: (properties['paddingBottom'] is num) ? properties['paddingBottom'].toDouble() : 0.0,
      left: (properties['paddingLeft'] is num) ? properties['paddingLeft'].toDouble() : 0.0,
      onChanged: (vals) {
        provider.updateNodeProperties(node, {
          ...properties,
          'paddingTop': vals['top'] ?? 0.0,
          'paddingRight': vals['right'] ?? 0.0,
          'paddingBottom': vals['bottom'] ?? 0.0,
          'paddingLeft': vals['left'] ?? 0.0,
        });
      },
    ),
    buildSectionHeader('Margin'),
    EdgeInsetsEditor(
      label: 'Margin',
      top: (properties['marginTop'] is num) ? properties['marginTop'].toDouble() : 0.0,
      right: (properties['marginRight'] is num) ? properties['marginRight'].toDouble() : 0.0,
      bottom: (properties['marginBottom'] is num) ? properties['marginBottom'].toDouble() : 0.0,
      left: (properties['marginLeft'] is num) ? properties['marginLeft'].toDouble() : 0.0,
      onChanged: (vals) {
        provider.updateNodeProperties(node, {
          ...properties,
          'marginTop': vals['top'] ?? 0.0,
          'marginRight': vals['right'] ?? 0.0,
          'marginBottom': vals['bottom'] ?? 0.0,
          'marginLeft': vals['left'] ?? 0.0,
        });
      },
    ),
  ]);

  return editors;
} 