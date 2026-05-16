import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';

class AspectRatioBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    final child = node.children.isNotEmpty
        ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode)
        : Container(color: Colors.grey.withOpacity(0.3));

    return AspectRatio(
      aspectRatio: (node.properties['aspectRatio'] as num?)?.toDouble() ?? 1.0,
      child: child,
    );
  }
}
