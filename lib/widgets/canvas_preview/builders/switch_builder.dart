import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class SwitchBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return Switch(
      value: inputValue<bool>(context, node, node.properties['value'] == true),
      onChanged: (bool newValue) => inputChanged(context, node, newValue),
      activeColor: parseColor(node.properties['activeColor'], context),
      inactiveThumbColor: parseColor(node.properties['inactiveThumbColor'], context),
    );
  }
} 