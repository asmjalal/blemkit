import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';
import '../../../utils/color_utils.dart';

class AvatarBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    final src = node.properties['src']?.toString();
    final child = node.children.isNotEmpty
        ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode)
        : null;

    return CircleAvatar(
      radius: (node.properties['radius'] as num?)?.toDouble() ?? 20.0,
      backgroundColor: parseColor(node.properties['backgroundColor'], context),
      foregroundColor: parseColor(node.properties['foregroundColor'], context),
      backgroundImage: src != null ? NetworkImage(src) : null,
      child: child,
    );
  }
}
