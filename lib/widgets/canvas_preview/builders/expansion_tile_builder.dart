import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class ExpansionTileBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return ExpansionTile(
      title: node.properties['title'] != null
          ? WidgetBuilderFactory.buildWidget(context, WidgetNode.fromJson(node.properties['title']), hoveredNode)
          : const Text('Expansion Tile Title'),
      leading: node.properties['leading'] != null
          ? WidgetBuilderFactory.buildWidget(context, WidgetNode.fromJson(node.properties['leading']), hoveredNode)
          : null,
      trailing: node.properties['trailing'] != null
          ? WidgetBuilderFactory.buildWidget(context, WidgetNode.fromJson(node.properties['trailing']), hoveredNode)
          : null,
      children: node.children.map((child) => WidgetBuilderFactory.buildWidget(context, child, hoveredNode)).toList(),
      initiallyExpanded: node.properties['initiallyExpanded'] ?? false,
      backgroundColor: parseColor(node.properties['backgroundColor'], context),
    );
  }


} 