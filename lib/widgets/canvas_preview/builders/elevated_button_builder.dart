import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class ElevatedButtonBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: parseColor(node.properties['backgroundColor'], context),
        foregroundColor: parseColor(node.properties['foregroundColor'], context),
        padding: parseEdgeInsets(node.properties['padding']),
      ),
      child: node.children.isNotEmpty 
          ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode) 
          : Text(safeString(node.properties['text'], fallback: 'Button')),
    );
  }


} 