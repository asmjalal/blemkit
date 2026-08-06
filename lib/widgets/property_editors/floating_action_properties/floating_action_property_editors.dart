import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../../../models/widget_node.dart';
import '../text_field.dart';
import '../section_header.dart';
import '../color_picker_field.dart';
import '../icon_picker_field.dart';
import '../numeric_property_field.dart';
import '../dropdown_field.dart';
import '../slider_field.dart';
import 'package:designflutterkit/utils/color_utils.dart';

List<Widget> buildFloatingActionPropertyEditors(BuildContext context, WidgetNode node) {
  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
  final properties = node.properties;
  final editors = <Widget>[];

  String _safeValue(dynamic val, String fallback) {
    if (val == null || val is! String) return fallback;
    return val.contains('.') ? val.split('.').last : val;
  }

  editors.addAll([
    // ── Icon ─────────────────────────────────────────────────────────────────
    buildSectionHeader('Icon'),
    IconPickerField(
      label: 'Icon',
      value: properties['icon'] as String? ?? 'Icons.add',
      onChanged: (value) {
        properties['icon'] = value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildNumericPropertyField(
      label: 'Icon Size',
      value: (properties['iconSize'] ?? 24.0).toStringAsFixed(0),
      onChanged: (value) {
        properties['iconSize'] = double.tryParse(value) ?? 24.0;
        provider.updateNodeProperties(node, properties);
      },
    ),

    // ── Label (for extended FAB) ──────────────────────────────────────────────
    const SizedBox(height: 8),
    buildSectionHeader('Label'),
    buildTextField(
      'Label Text',
      properties['label'] as String? ?? '',
      (value) {
        properties['label'] = value ?? '';
        provider.updateNodeProperties(node, properties);
      },
    ),

    // ── Shape & Size ─────────────────────────────────────────────────────────
    const SizedBox(height: 8),
    buildSectionHeader('Shape & Size'),
    buildDropdownField(
      'Shape',
      _safeValue(properties['shape'], 'circle'),
      ['circle', 'roundedSquare', 'extended'],
      (value) {
        properties['shape'] = value ?? 'circle';
        provider.updateNodeProperties(node, properties);
      },
    ),
    const SizedBox(height: 8),
    buildDropdownField(
      'Size',
      _safeValue(properties['fabSize'], 'regular'),
      ['mini', 'small', 'regular', 'large'],
      (value) {
        properties['fabSize'] = value ?? 'regular';
        provider.updateNodeProperties(node, properties);
      },
    ),

    // ── Colors ───────────────────────────────────────────────────────────────
    const SizedBox(height: 8),
    buildSectionHeader('Colors'),
    buildPropertyRow([
      ColorPickerField(
        label: 'Background',
        color: ColorUtils.parseColor(properties['backgroundColor'], Colors.blue),
        onColorChanged: (color) {
          properties['backgroundColor'] = color.value.toString();
          provider.updateNodeProperties(node, properties);
        },
      ),
      ColorPickerField(
        label: 'Icon Color',
        color: ColorUtils.parseColor(properties['foregroundColor'], Colors.white),
        onColorChanged: (color) {
          properties['foregroundColor'] = color.value.toString();
          provider.updateNodeProperties(node, properties);
        },
      ),
    ]),

    // ── Elevation ────────────────────────────────────────────────────────────
    const SizedBox(height: 8),
    buildSectionHeader('Elevation'),
    buildSliderField(
      'Elevation',
      (properties['elevation'] is num)
          ? (properties['elevation'] as num).toDouble()
          : 6.0,
      0.0,
      24.0,
      (value) {
        properties['elevation'] = (value == null || value.isNaN) ? 6.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),

    // ── Navigation ───────────────────────────────────────────────────────────
    const SizedBox(height: 8),
    buildSectionHeader('Navigation'),
    buildDropdownField(
      'Navigate To',
      provider.screens.any((s) => s.id == properties['navigateTo'])
          ? provider.screens
                  .firstWhere((s) => s.id == properties['navigateTo'])
                  .properties['pageName'] as String? ??
              'Page'
          : 'None',
      ['None', ...provider.screens.map((s) => s.properties['pageName'] as String? ?? 'Page')],
      (value) {
        if (value == 'None' || value == null) {
          properties['navigateTo'] = null;
        } else {
          try {
            final target =
                provider.screens.firstWhere((s) => s.properties['pageName'] == value);
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