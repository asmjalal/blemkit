import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class CheckboxListTileBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return CheckboxListTile(
      title: safeWidget(context, node.properties['title'], hoveredNode, fallback: null),
      value: node.properties['value'] ?? false,
      onChanged: (bool? newValue) {},
      controlAffinity: parseListTileControlAffinity(node.properties['controlAffinity']),
      activeColor: parseColor(node.properties['activeColor'], context),
      checkColor: parseColor(node.properties['checkColor'], context),
    );
  }

  ListTileControlAffinity? parseListTileControlAffinity(dynamic value) {
    switch (value) {
      case 'leading':
        return ListTileControlAffinity.leading;
      case 'trailing':
        return ListTileControlAffinity.trailing;
      case 'platform':
        return ListTileControlAffinity.platform;
      default:
        return null;
    }
  }
} 