import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';

class ConstrainedBoxBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    final child = node.children.isNotEmpty
        ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode)
        : const SizedBox.shrink();

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: (node.properties['minWidth'] as num?)?.toDouble() ?? 0.0,
        maxWidth: (node.properties['maxWidth'] as num?)?.toDouble() ?? double.infinity,
        minHeight: (node.properties['minHeight'] as num?)?.toDouble() ?? 0.0,
        maxHeight: (node.properties['maxHeight'] as num?)?.toDouble() ?? double.infinity,
      ),
      child: child,
    );
  }
}
