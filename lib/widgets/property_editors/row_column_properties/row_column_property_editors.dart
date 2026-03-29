import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../../../models/widget_node.dart';
import '../dropdown_field.dart';
import '../section_header.dart';
import '../slider_field.dart';
import '../edge_insets_editor.dart';
import '../numeric_property_field.dart';


// Helper to convert enum string (e.g., "CrossAxisAlignment.start") to simple string ("start")
String _enumToString(String? enumValue) {
  if (enumValue == null) return 'center'; // Default or handle as needed
  final parts = enumValue.split('.');
  return parts.length > 1 ? parts.last : enumValue;
}


List<Widget> buildRowPropertyEditors(BuildContext context, WidgetNode node) {
  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
  final properties = node.properties;
  final editors = <Widget>[];

  editors.addAll([
    buildSectionHeader('Row Layout'),
    buildPropertyRow([
      buildDropdownField(
        'Size',
        _enumToString(properties['mainAxisSize'] as String? ?? 'max'),
        ['max', 'min'],
        (value) {
          properties['mainAxisSize'] = value ?? 'max';
          provider.updateNodeProperties(node, properties);
        },
      ),
      buildDropdownField(
        'Main Align',
        _enumToString((properties['mainAxisAlignment'] as String? ?? 'start')),
        ['start', 'end', 'center', 'spaceBetween', 'spaceAround', 'spaceEvenly'],
        (value) {
          properties['mainAxisAlignment'] = value ?? 'start';
          provider.updateNodeProperties(node, properties);
        },
      ),
    ]),
    buildPropertyRow([
      buildDropdownField(
        'Cross Align',
        _enumToString(properties['crossAxisAlignment'] as String? ?? 'center'),
        ['start', 'center', 'end', 'stretch', 'baseline'],
        (value) {
          properties['crossAxisAlignment'] = value ?? 'center';
          provider.updateNodeProperties(node, properties);
        },
      ),
      buildDropdownField(
        'Direction',
        _enumToString(properties['verticalDirection'] as String? ?? 'down'),
        ['down', 'up'],
        (value) {
          properties['verticalDirection'] = value ?? 'down';
          provider.updateNodeProperties(node, properties);
        },
      ),
    ]),
    buildPropertyRow([
      buildDropdownField(
        'Text Dir',
        _enumToString(properties['textDirection'] as String? ?? 'ltr'),
        ['ltr', 'rtl'],
        (value) {
          properties['textDirection'] = value ?? 'ltr';
          provider.updateNodeProperties(node, properties);
        },
      ),
      SwitchListTile(
        title: const Text('Scroll', style: TextStyle(color: Colors.white70, fontSize: 11)),
        contentPadding: EdgeInsets.zero,
        value: properties['scrollable'] == true,
        onChanged: (value) {
          properties['scrollable'] = (value == null) ? false : value;
          provider.updateNodeProperties(node, properties);
        },
      ),
    ]),
    buildSectionHeader('Padding'),
    buildSliderField(
      'Padding Top',
      (properties['paddingTop'] is num && properties['paddingTop'] != null) ? properties['paddingTop'].toDouble() : 0.0,
      0.0,
      64.0,
      (value) {
        properties['paddingTop'] = (value.isNaN) ? 0.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSliderField(
      'Padding Bottom',
      (properties['paddingBottom'] is num && properties['paddingBottom'] != null) ? properties['paddingBottom'].toDouble() : 0.0,
      0.0,
      64.0,
      (value) {
        properties['paddingBottom'] = (value.isNaN) ? 0.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSliderField(
      'Padding Left',
      (properties['paddingLeft'] is num && properties['paddingLeft'] != null) ? properties['paddingLeft'].toDouble() : 0.0,
      0.0,
      64.0,
      (value) {
        properties['paddingLeft'] = (value.isNaN) ? 0.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSliderField(
      'Padding Right',
      (properties['paddingRight'] is num && properties['paddingRight'] != null) ? properties['paddingRight'].toDouble() : 0.0,
      0.0,
      64.0,
      (value) {
        properties['paddingRight'] = (value.isNaN) ? 0.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSectionHeader('Margin'),
    buildSliderField(
      'Margin Top',
      (properties['marginTop'] is num && properties['marginTop'] != null) ? properties['marginTop'].toDouble() : 0.0,
      0.0,
      64.0,
      (value) {
        properties['marginTop'] = (value.isNaN) ? 0.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSliderField(
      'Margin Bottom',
      (properties['marginBottom'] is num && properties['marginBottom'] != null) ? properties['marginBottom'].toDouble() : 0.0,
      0.0,
      64.0,
      (value) {
        properties['marginBottom'] = (value.isNaN) ? 0.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSliderField(
      'Margin Left',
      (properties['marginLeft'] is num && properties['marginLeft'] != null) ? properties['marginLeft'].toDouble() : 0.0,
      0.0,
      64.0,
      (value) {
        properties['marginLeft'] = (value.isNaN) ? 0.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSliderField(
      'Margin Right',
      (properties['marginRight'] is num && properties['marginRight'] != null) ? properties['marginRight'].toDouble() : 0.0,
      0.0,
      64.0,
      (value) {
        properties['marginRight'] = (value.isNaN) ? 0.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
  ]);

  return editors;
}

List<Widget> buildColumnPropertyEditors(BuildContext context, WidgetNode node) {
  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
  final properties = node.properties;
  final editors = <Widget>[];

  editors.addAll([
    buildSectionHeader('Column Layout'),
    buildPropertyRow([
      buildDropdownField(
        'Size',
        _enumToString(properties['mainAxisSize'] as String? ?? 'max'),
        ['max', 'min'],
        (value) {
          properties['mainAxisSize'] = value ?? 'max';
          provider.updateNodeProperties(node, properties);
        },
      ),
      buildDropdownField(
        'Main Align',
        _enumToString((properties['mainAxisAlignment'] as String? ?? 'start')),
        ['start', 'end', 'center', 'spaceBetween', 'spaceAround', 'spaceEvenly'],
        (value) {
          properties['mainAxisAlignment'] = value ?? 'start';
          provider.updateNodeProperties(node, properties);
        },
      ),
    ]),
    buildPropertyRow([
      buildDropdownField(
        'Cross Align',
        _enumToString(properties['crossAxisAlignment'] as String? ?? 'center'),
        ['start', 'center', 'end', 'stretch', 'baseline'],
        (value) {
          properties['crossAxisAlignment'] = value ?? 'center';
          provider.updateNodeProperties(node, properties);
        },
      ),
      buildDropdownField(
        'Direction',
        _enumToString(properties['verticalDirection'] as String? ?? 'down'),
        ['down', 'up'],
        (value) {
          properties['verticalDirection'] = value ?? 'down';
          provider.updateNodeProperties(node, properties);
        },
      ),
    ]),
    buildPropertyRow([
      buildDropdownField(
        'Text Dir',
        _enumToString(properties['textDirection'] as String? ?? 'ltr'),
        ['ltr', 'rtl'],
        (value) {
          properties['textDirection'] = value ?? 'ltr';
          provider.updateNodeProperties(node, properties);
        },
      ),
      const SizedBox.shrink(), // Spacer for 2-column consistency
    ]),
    buildSliderField(
      'Padding (all)',
      (properties['padding'] is num && properties['padding'] != null) ? properties['padding'].toDouble() : 0.0,
      0.0,
      64.0,
      (value) {
        properties['padding'] = (value.isNaN) ? 0.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSliderField(
      'Margin (all)',
      (properties['margin'] is num && properties['margin'] != null) ? properties['margin'].toDouble() : 0.0,
      0.0,
      64.0,
      (value) {
        properties['margin'] = (value.isNaN) ? 0.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
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