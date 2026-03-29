import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class AlertDialogBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return AlertDialog(
      title: node.properties['title'] != null
          ? WidgetBuilderFactory.buildWidget(context, WidgetNode.fromJson(node.properties['title']), hoveredNode)
          : null,
      content: node.properties['content'] != null
          ? WidgetBuilderFactory.buildWidget(context, WidgetNode.fromJson(node.properties['content']), hoveredNode)
          : null,
      actions: (node.properties['actions'] as List<dynamic>? ?? []).map((action) {
        return WidgetBuilderFactory.buildWidget(context, WidgetNode.fromJson(action), hoveredNode);
      }).toList(),
    );
  }


} 