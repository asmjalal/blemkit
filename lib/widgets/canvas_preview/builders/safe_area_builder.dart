import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';

class SafeAreaBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    final child = node.children.isNotEmpty
        ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode)
        : const SizedBox.shrink();

    return SafeArea(
      left: node.properties['left'] ?? true,
      top: node.properties['top'] ?? true,
      right: node.properties['right'] ?? true,
      bottom: node.properties['bottom'] ?? true,
      child: child,
    );
  }
}
