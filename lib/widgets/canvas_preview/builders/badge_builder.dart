import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';
import '../../../utils/color_utils.dart';

class BadgeBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    final child = node.children.isNotEmpty
        ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode)
        : const Icon(Icons.notifications);

    return Badge(
      label: node.properties['label'] != null ? Text(node.properties['label'].toString()) : null,
      isLabelVisible: node.properties['isLabelVisible'] ?? true,
      backgroundColor: parseColor(node.properties['backgroundColor'], context),
      textColor: parseColor(node.properties['textColor'], context),
      child: child,
    );
  }
}
