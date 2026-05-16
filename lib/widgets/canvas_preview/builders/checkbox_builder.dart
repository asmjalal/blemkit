import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class CheckboxBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return Checkbox(
      value: node.properties['value'] ?? false,
      onChanged: (bool? newValue) {},
      activeColor: parseColor(node.properties['activeColor'], context),
      checkColor: parseColor(node.properties['checkColor'], context),
    );
  }
} 