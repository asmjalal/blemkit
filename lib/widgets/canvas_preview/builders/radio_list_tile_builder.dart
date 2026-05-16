import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class RadioListTileBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return RadioListTile<String>(
      title: safeWidget(context, node.properties['title'], hoveredNode, fallback: null),
      value: node.properties['value'] ?? '',
      groupValue: node.properties['groupValue'] ?? '',
      onChanged: (String? newValue) {},
      activeColor: parseColor(node.properties['activeColor'], context),
      controlAffinity: parseListTileControlAffinity(node.properties['controlAffinity']),
      secondary: node.properties['secondary'] != null
          ? WidgetBuilderFactory.buildWidget(context, WidgetNode.fromJson(node.properties['secondary']), hoveredNode)
          : null,
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