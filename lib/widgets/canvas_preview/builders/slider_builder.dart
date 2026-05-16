import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class SliderBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return Slider(
      value: (node.properties['value'] as num?)?.toDouble() ?? 0.0,
      min: (node.properties['min'] as num?)?.toDouble() ?? 0.0,
      max: (node.properties['max'] as num?)?.toDouble() ?? 1.0,
      onChanged: (double newValue) {},
      activeColor: parseColor(node.properties['activeColor'], context),
      inactiveColor: parseColor(node.properties['inactiveColor'], context),
      divisions: node.properties['divisions'] as int?,
      label: node.properties['label'] as String?,
    );
  }
} 