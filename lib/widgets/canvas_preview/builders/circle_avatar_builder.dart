import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class CircleAvatarBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return CircleAvatar(
      radius: (node.properties['radius'] as num?)?.toDouble(),
      backgroundColor: parseColor(node.properties['backgroundColor'], context),
      backgroundImage: node.properties['backgroundImage'] != null
          ? NetworkImage(node.properties['backgroundImage'] as String)
          : null,
      child: node.children.isNotEmpty ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode) : null,
    );
  }


} 