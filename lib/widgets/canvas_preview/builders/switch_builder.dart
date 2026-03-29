import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class SwitchBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return Switch(
      value: node.properties['value'] ?? false,
      onChanged: (bool newValue) {},
      activeColor: parseColor(node.properties['activeColor']),
      inactiveThumbColor: parseColor(node.properties['inactiveThumbColor']),
    );
  }
} 