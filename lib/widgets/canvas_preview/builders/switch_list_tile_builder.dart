import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class SwitchListTileBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return SwitchListTile(
      title: safeWidget(context, node.properties['title'], hoveredNode, fallback: null),
      value: node.properties['value'] ?? false,
      onChanged: (bool newValue) {},
      activeColor: parseColor(node.properties['activeColor'], context),
      inactiveThumbColor: parseColor(node.properties['inactiveThumbColor'], context),
      secondary: node.properties['secondary'] != null
          ? WidgetBuilderFactory.buildWidget(context, WidgetNode.fromJson(node.properties['secondary']), hoveredNode)
          : null,
    );
  }


} 