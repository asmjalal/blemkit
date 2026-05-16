import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../../../models/widget_node.dart';
import '../dropdown_field.dart';
import '../section_header.dart';
import '../color_picker_field.dart';
import '../icon_picker_field.dart';
import '../numeric_property_field.dart';
import 'package:designflutterkit/utils/color_utils.dart';

String _iconButtonIconString(Map<String, dynamic> properties) {
  final dynamic raw = properties['icon'];
  if (raw is String && raw.isNotEmpty) return raw;
  if (raw is Map<String, dynamic>) {
    try {
      if (raw['type'] == 'Icon' && raw['properties'] is Map) {
        final p = raw['properties'] as Map;
        if (p['icon'] is String) return p['icon'] as String;
      }
    } catch (_) {}
  }
  return 'Icons.star';
}

List<Widget> buildIconPropertyEditors(BuildContext context, WidgetNode node) {
  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
  final properties = node.properties;
  final editors = <Widget>[];

  editors.addAll([
    buildSectionHeader('Icon'),
    IconPickerField(
      label: 'Icon',
      value: properties['icon'] as String? ?? 'Icons.star',
      onChanged: (value) {
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

List<Widget> buildIconButtonPropertyEditors(BuildContext context, WidgetNode node) {
  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
  final properties = node.properties;
  final editors = <Widget>[];

  editors.addAll([
    buildSectionHeader('Icon button'),
    IconPickerField(
      label: 'Icon',
      value: _iconButtonIconString(properties),
      onChanged: (value) {
        properties['icon'] = value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    ColorPickerField(
      label: 'Icon color',
      color: ColorUtils.parseColor(properties['color'], Colors.white),
      onColorChanged: (color) {
        properties['color'] = color.value.toString();
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildNumericPropertyField(
      label: 'Icon size',
      value: (properties['size'] is num)
          ? (properties['size'] as num).toStringAsFixed(0)
          : (properties['size']?.toString() ?? '24'),
      onChanged: (value) {
        final n = double.tryParse(value);
        if (n != null) {
          properties['size'] = n;
          provider.updateNodeProperties(node, properties);
        }
      },
    ),
    const SizedBox(height: 8),
    buildSectionHeader('Navigation'),
    buildDropdownField(
      'Navigate to',
      provider.screens.any((s) => s.id == properties['navigateTo'])
          ? provider.screens.firstWhere((s) => s.id == properties['navigateTo']).properties['pageName'] as String? ?? 'Page'
          : 'None',
      ['None', ...provider.screens.map((s) => s.properties['pageName'] as String? ?? 'Page')],
      (value) {
        if (value == 'None') {
          properties['navigateTo'] = null;
        } else {
          try {
            final target = provider.screens.firstWhere((s) => s.properties['pageName'] == value);
            properties['navigateTo'] = target.id;
          } catch (_) {
            properties['navigateTo'] = null;
          }
        }
        provider.updateNodeProperties(node, properties);
      },
    ),
  ]);

  return editors;
}
