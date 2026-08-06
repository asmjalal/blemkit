import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class LinearProgressIndicatorBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    final color = parseColor(node.properties['color'], context);
    final value = parseDouble(node.properties['value']);

    return LinearProgressIndicator(
      color: color,
      value: value,
      backgroundColor: parseColor(node.properties['backgroundColor'], context),
      minHeight: parseDouble(node.properties['minHeight']),
    );
  }
}
