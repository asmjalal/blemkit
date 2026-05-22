import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../../../models/widget_node.dart';
import '../text_field.dart';
import '../section_header.dart';
import '../color_picker_field.dart';
import '../slider_field.dart';
import '../edge_insets_editor.dart';
import 'package:designflutterkit/utils/color_utils.dart';


List<Widget> buildCardPropertyEditors(BuildContext context, WidgetNode node) {
  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
  final properties = node.properties;
  final editors = <Widget>[];

  editors.addAll([
    buildSectionHeader('Card Style'),
    ColorPickerField(
      label: 'Background Color',
      color: ColorUtils.parseColor(properties['color'], Colors.white),
      onColorChanged: (color) {
        properties['color'] = color.value.toString();
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSliderField(
      'Elevation',
      (properties['elevation'] is num && properties['elevation'] != null)
          ? properties['elevation'].toDouble()
          : 1.0,
      0.0,
      24.0,
      (value) {
        properties['elevation'] = (value == null || value.isNaN) ? 1.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSliderField(
      'Radius',
      () {
        final shape = properties['shape'];
        if (shape is Map<String, dynamic> && shape['borderRadius'] != null) {
          return (shape['borderRadius'] as num).toDouble();
        }
        return 4.0;
      }(),
      0.0,
      64.0,
      (value) {
        final shape = properties['shape'];
        final Map<String, dynamic> newShape = (shape is Map<String, dynamic>)
            ? Map<String, dynamic>.from(shape)
            : <String, dynamic>{};
        newShape['borderRadius'] = (value == null || value.isNaN) ? 4.0 : value;
        properties['shape'] = newShape;
        provider.updateNodeProperties(node, properties);
      },
    ),
    const SizedBox(height: 12),
    EdgeInsetsEditor(
      label: 'Margin',
      top: () {
        final margin = properties['margin'];
        if (margin is Map<String, dynamic> && margin['top'] != null) return (margin['top'] as num).toDouble();
        return 0.0;
      }(),
      right: () {
        final margin = properties['margin'];
        if (margin is Map<String, dynamic> && margin['right'] != null) return (margin['right'] as num).toDouble();
        return 0.0;
      }(),
      bottom: () {
        final margin = properties['margin'];
        if (margin is Map<String, dynamic> && margin['bottom'] != null) return (margin['bottom'] as num).toDouble();
        return 0.0;
      }(),
      left: () {
        final margin = properties['margin'];
        if (margin is Map<String, dynamic> && margin['left'] != null) return (margin['left'] as num).toDouble();
        return 0.0;
      }(),
      onChanged: (vals) {
        final margin = properties['margin'];
        final Map<String, dynamic> newMargin = (margin is Map<String, dynamic>)
            ? Map<String, dynamic>.from(margin)
            : <String, dynamic>{};
        newMargin['top'] = vals['top'] ?? 0.0;
        newMargin['bottom'] = vals['bottom'] ?? 0.0;
        newMargin['left'] = vals['left'] ?? 0.0;
        newMargin['right'] = vals['right'] ?? 0.0;
        properties['margin'] = newMargin;
        provider.updateNodeProperties(node, properties);
      },
    ),
  ]);

  return editors;
} 