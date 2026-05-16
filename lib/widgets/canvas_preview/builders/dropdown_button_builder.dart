import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class DropdownButtonBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return DropdownButton<String>(
      value: node.properties['value'] as String?,
      items: (node.properties['items'] as List<dynamic>? ?? []).map((item) {
        return DropdownMenuItem<String>(
          value: item['value'] as String,
          child: Text(item['label'] as String),
        );
      }).toList(),
      onChanged: (value) {},
      hint: safeWidget(context, node.properties['hint'], hoveredNode, fallback: null),
    );
  }
} 