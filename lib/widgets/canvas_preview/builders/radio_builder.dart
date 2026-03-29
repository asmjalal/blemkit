import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class RadioBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return Radio<String>(
      value: node.properties['value'] ?? '',
      groupValue: node.properties['groupValue'] ?? '',
      onChanged: (String? newValue) {},
      activeColor: parseColor(node.properties['activeColor']),
    );
  }
} 