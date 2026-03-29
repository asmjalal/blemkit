import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';

class SizedBoxBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return SizedBox(
      width: node.properties['width']?.toDouble(),
      height: node.properties['height']?.toDouble(),
      child: node.children.isNotEmpty 
          ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode) 
          : null,
    );
  }
} 