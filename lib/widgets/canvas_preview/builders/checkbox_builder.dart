import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class CheckboxBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return Checkbox(
      value: inputValue<bool>(context, node, node.properties['value'] == true),
      onChanged: (bool? newValue) => inputChanged(context, node, newValue ?? false),
      activeColor: parseColor(node.properties['activeColor'], context),
      checkColor: parseColor(node.properties['checkColor'], context),
    );
  }
} 