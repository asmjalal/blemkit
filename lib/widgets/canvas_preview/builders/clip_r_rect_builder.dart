import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';

class ClipRRectBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    final child = node.children.isNotEmpty
        ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode)
        : const SizedBox.shrink();

    final borderRadiusValue = (node.properties['borderRadius'] as num?)?.toDouble() ?? 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadiusValue),
      child: child,
    );
  }
}
