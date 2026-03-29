import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class SnackBarBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return SnackBar(
      content: node.properties['content'] != null
          ? WidgetBuilderFactory.buildWidget(context, WidgetNode.fromJson(node.properties['content']), hoveredNode)
          : const Text('Snackbar Message'),
      backgroundColor: parseColor(node.properties['backgroundColor']),
      duration: Duration(milliseconds: node.properties['duration'] ?? 4000),
      action: node.properties['action'] != null
          ? SnackBarAction(
              label: node.properties['action']['label'] as String,
              onPressed: () {},
            )
          : null,
    );
  }


} 