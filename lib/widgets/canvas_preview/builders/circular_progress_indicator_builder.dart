import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class CircularProgressIndicatorBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    final color = parseColor(node.properties['color'], context);
    final strokeWidth = parseDouble(node.properties['strokeWidth']) ?? 4.0;
    final value = parseDouble(node.properties['value']);

    return CircularProgressIndicator(
      color: color,
      strokeWidth: strokeWidth,
      value: value,
      backgroundColor: parseColor(node.properties['backgroundColor'], context),
    );
  }
}
