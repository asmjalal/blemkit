import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class ChipBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return Chip(
      label: node.properties['label'] != null
          ? WidgetBuilderFactory.buildWidget(context, WidgetNode.fromJson(node.properties['label']), hoveredNode)
          : const Text('Chip Label'),
      avatar: node.properties['avatar'] != null
          ? WidgetBuilderFactory.buildWidget(context, WidgetNode.fromJson(node.properties['avatar']), hoveredNode)
          : null,
      backgroundColor: parseColor(node.properties['backgroundColor']),
      deleteIcon: node.properties['deleteIcon'] != null
          ? WidgetBuilderFactory.buildWidget(context, WidgetNode.fromJson(node.properties['deleteIcon']), hoveredNode)
          : null,
      onDeleted: node.properties['onDeleted'] != null ? () {} : null,
    );
  }


} 