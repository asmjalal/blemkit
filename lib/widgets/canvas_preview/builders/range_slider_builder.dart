import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class RangeSliderBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    final min = (node.properties['min'] as num?)?.toDouble() ?? 0.0;
    final max = (node.properties['max'] as num?)?.toDouble() ?? 100.0;
    final startValue = (node.properties['startValue'] as num?)?.toDouble() ?? (min + (max - min) * 0.25);
    final endValue = (node.properties['endValue'] as num?)?.toDouble() ?? (min + (max - min) * 0.75);
    final divisions = node.properties['divisions'] as int?;

    return RangeSlider(
      values: RangeValues(
        startValue.clamp(min, max),
        endValue.clamp(min, max),
      ),
      min: min,
      max: max,
      divisions: divisions,
      labels: divisions != null ? RangeLabels(startValue.toStringAsFixed(1), endValue.toStringAsFixed(1)) : null,
      onChanged: (values) {}, // Canvas preview is non-interactive for state
    );
  }
}
