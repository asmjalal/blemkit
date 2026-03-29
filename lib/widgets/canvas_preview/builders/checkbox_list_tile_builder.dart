import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class CheckboxListTileBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return CheckboxListTile(
      title: node.properties['title'] != null ? Text(node.properties['title']) : null,
      value: node.properties['value'] ?? false,
      onChanged: (bool? newValue) {},
      controlAffinity: parseListTileControlAffinity(node.properties['controlAffinity']),
      activeColor: parseColor(node.properties['activeColor']),
      checkColor: parseColor(node.properties['checkColor']),
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