import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class SliderBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    final min = (node.properties['min'] as num?)?.toDouble() ?? 0.0;
    final max = (node.properties['max'] as num?)?.toDouble() ?? 1.0;
    return Slider(
      value: inputValue<double>(context, node, (node.properties['value'] as num?)?.toDouble() ?? 0.0).clamp(min, max),
      min: min,
      max: max,
      onChanged: (double newValue) => inputChanged(context, node, newValue),
      activeColor: parseColor(node.properties['activeColor'], context),
      inactiveColor: parseColor(node.properties['inactiveColor'], context),
      divisions: node.properties['divisions'] as int?,
      label: node.properties['label'] as String?,
    );
  }
} 