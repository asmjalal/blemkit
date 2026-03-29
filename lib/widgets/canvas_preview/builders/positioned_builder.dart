import 'package:designflutterkit/widgets/canvas_preview/builders/widget_builder_factory.dart';
import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class PositionedBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return Positioned(
      left: node.properties['left']?.toDouble(),
      top: node.properties['top']?.toDouble(),
      right: node.properties['right']?.toDouble(),
      bottom: node.properties['bottom']?.toDouble(),
      width: node.properties['width']?.toDouble(),
      height: node.properties['height']?.toDouble(),
      child: node.children.isNotEmpty 
          ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode) 
          : const SizedBox(),
    );
  }
}