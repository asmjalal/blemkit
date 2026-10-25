import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../../../models/widget_node.dart';
import '../text_field.dart';
import '../section_header.dart';
import '../color_picker_field.dart';
import 'package:designflutterkit/utils/color_utils.dart';

import '../slider_field.dart';
import '../dropdown_field.dart';
import '../color_picker_field.dart';
import 'package:designflutterkit/utils/color_utils.dart';


import '../numeric_property_field.dart';

List<Widget> buildButtonPropertyEditors(BuildContext context, WidgetNode node) {
  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
  final properties = node.properties;
  final editors = <Widget>[];

  String _safeValue(dynamic val, String fallback) {
    if (val == null || val is! String) return fallback;
    return val.contains('.') ? val.split('.').last : val;
  }

  editors.addAll([
    buildSectionHeader('Button Text'),
    buildTextField(
      'Text',
      properties['text'] as String? ?? 'Button',
      (value) {
        properties['text'] = (value == null) ? 'Button' : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildPropertyRow([
      buildNumericPropertyField(
        label: 'Size',
        value: (properties['fontSize'] ?? 16.0).toStringAsFixed(0),
        onChanged: (value) {
          properties['fontSize'] = double.tryParse(value) ?? 16.0;
          provider.updateNodeProperties(node, properties);
        },
      ),
      buildDropdownField(
        'Weight',
        _safeValue(properties['fontWeight'], 'w600'),
        ['normal', 'bold', 'w100', 'w200', 'w300', 'w400', 'w500', 'w600', 'w700', 'w800', 'w900'],
        (value) {
          properties['fontWeight'] = value ?? 'w600';
          provider.updateNodeProperties(node, properties);
        },
      ),
    ]),
    buildPropertyRow([
      buildTextField(
        'Family',
        properties['fontFamily'] as String? ?? 'Primary',
        (value) {
          properties['fontFamily'] = value ?? 'Primary';
          provider.updateNodeProperties(node, properties);
        },
      ),
      buildSliderField(
        'Spacing',
        (properties['letterSpacing'] is num && properties['letterSpacing'] != null) ? properties['letterSpacing'].toDouble() : 0.0,
        0.0,
        10.0,
        (value) {
          properties['letterSpacing'] = (value == null || value.isNaN) ? 0.0 : value;
          provider.updateNodeProperties(node, properties);
        },
      ),
    ]),
    const SizedBox(height: 12),
    buildSectionHeader('Button Style'),
    buildPropertyRow([
      buildNumericPropertyField(
        label: 'Width',
        value: (properties['width'] ?? 160.0).toStringAsFixed(0),
        onChanged: (value) {
          properties['width'] = double.tryParse(value) ?? 160.0;
          provider.updateNodeProperties(node, properties);
        },
      ),
      buildNumericPropertyField(
        label: 'Height',
        value: (properties['height'] ?? 50.0).toStringAsFixed(0),
        onChanged: (value) {
          properties['height'] = double.tryParse(value) ?? 50.0;
          provider.updateNodeProperties(node, properties);
        },
      ),
    ]),
    buildPropertyRow([
      ColorPickerField(
        label: 'Fill',
        color: ColorUtils.parseColor(properties['fillColor'], Colors.blue),
        onColorChanged: (color) {
          properties['fillColor'] = color.value.toString();
          provider.updateNodeProperties(node, properties);
        },
      ),
      buildSliderField(
        'Elev',
        (properties['buttonElevation'] is num && properties['buttonElevation'] != null) ? properties['buttonElevation'].toDouble() : 2.0,
        0.0,
        24.0,
        (value) {
          properties['buttonElevation'] = (value == null || value.isNaN) ? 2.0 : value;
          provider.updateNodeProperties(node, properties);
        },
      ),
    ]),
    buildPropertyRow([
      ColorPickerField(
        label: 'Border',
        color: ColorUtils.parseColor(properties['borderColor'], Colors.transparent),
        onColorChanged: (color) {
          properties['borderColor'] = color.value.toString();
          provider.updateNodeProperties(node, properties);
        },
      ),
      buildPropertyRow([
        buildNumericPropertyField(
          label: 'Width',
          value: (properties['borderWidth'] ?? 1.0).toStringAsFixed(0),
          onChanged: (value) {
            properties['borderWidth'] = double.tryParse(value) ?? 1.0;
            provider.updateNodeProperties(node, properties);
          },
        ),
      ]),
    ]),
    buildPropertyRow([
      buildSliderField(
        'Radius',
        (properties['borderRadius'] is num && properties['borderRadius'] != null) ? properties['borderRadius'].toDouble() : 4.0,
        0.0,
        100.0,
        (value) {
          properties['borderRadius'] = (value == null || value.isNaN) ? 4.0 : value;
          provider.updateNodeProperties(node, properties);
        },
      ),
      buildNumericPropertyField(
        label: 'Padding',
        value: (properties['padding'] ?? 12.0).toStringAsFixed(0),
        onChanged: (value) {
          properties['padding'] = double.tryParse(value) ?? 12.0;
          provider.updateNodeProperties(node, properties);
        },
      ),
    ]),
    buildSectionHeader('Shadows'),
    ElevatedButton.icon(
      icon: const Icon(Icons.add),
      label: const Text('Add Shadow'),
      onPressed: () {
        // Implement shadow adding logic
      },
    ),
    buildSectionHeader('Button Default Style'),
    buildTextField(
      'Width',
      properties['width']?.toString() ?? '160',
      (value) {
        properties['width'] = double.tryParse(value ?? '160') ?? 160.0;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildTextField(
      'Height',
      properties['height']?.toString() ?? '50',
      (value) {
        properties['height'] = double.tryParse(value ?? '50') ?? 50.0;
        provider.updateNodeProperties(node, properties);
      },
    ),
    ColorPickerField(
      label: 'Fill Color',
      color: ColorUtils.parseColor(properties['fillColor'], Colors.blue),
      onColorChanged: (color) {
        properties['fillColor'] = color.value.toString();
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSliderField(
      'Elevation',
      (properties['buttonElevation'] is num && properties['buttonElevation'] != null) ? properties['buttonElevation'].toDouble() : 2.0,
      0.0,
      24.0,
      (value) {
        properties['buttonElevation'] = (value == null || value.isNaN) ? 2.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    ColorPickerField(
      label: 'Border Color',
      color: ColorUtils.parseColor(properties['borderColor'], Colors.transparent),
      onColorChanged: (color) {
        properties['borderColor'] = color.value.toString();
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildTextField(
      'Border Width',
      properties['borderWidth']?.toString() ?? '1',
      (value) {
        properties['borderWidth'] = double.tryParse(value ?? '1') ?? 1.0;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSliderField(
      'Border Radius',
      (properties['borderRadius'] is num && properties['borderRadius'] != null) ? properties['borderRadius'].toDouble() : 4.0,
      0.0,
      100.0,
      (value) {
        properties['borderRadius'] = (value == null || value.isNaN) ? 4.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildTextField(
      'Button Padding',
      properties['padding']?.toString() ?? '',
      (value) {
        properties['padding'] = double.tryParse(value ?? '') ?? null;
        provider.updateNodeProperties(node, properties);
      },
    ),
    SwitchListTile(
      title: const Text('Show Loading Indicator'),
      value: properties['showLoadingIndicator'] == true,
      onChanged: (value) {
        properties['showLoadingIndicator'] = value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSectionHeader('Button Disable Options'),
    SwitchListTile(
      title: const Text('Button Disable Options'),
      value: properties['disableOptions'] == true,
      onChanged: (value) {
        properties['disableOptions'] = value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSectionHeader('Button Hover Style'),
    SwitchListTile(
      title: const Text('Button Hover Style'),
      value: properties['hoverStyle'] == true,
      onChanged: (value) {
        properties['hoverStyle'] = value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSectionHeader('Icon Properties'),
    buildTextField(
      'Icon',
      properties['icon']?.toString() ?? '',
      (value) {
        properties['icon'] = value;
        provider.updateNodeProperties(node, properties);
      },
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