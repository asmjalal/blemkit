import 'package:designflutterkit/widgets/canvas_preview/builders/widget_builder_factory.dart';
import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class PositionedBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return Positioned(
      left: parseDouble(node.properties['left']),
      top: parseDouble(node.properties['top']),
      right: parseDouble(node.properties['right']),
      bottom: parseDouble(node.properties['bottom']),
      width: parseDouble(node.properties['width']),
      height: parseDouble(node.properties['height']),
      child: node.children.isNotEmpty 
          ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode) 
          : const SizedBox(),
    );
  }
}