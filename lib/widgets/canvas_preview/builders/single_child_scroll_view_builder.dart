import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';

class SingleChildScrollViewBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return SingleChildScrollView(
      padding: parseEdgeInsets(node.properties['padding']),
      scrollDirection: parseAxis(node.properties['scrollDirection']) ?? Axis.vertical,
      child: node.children.isNotEmpty 
          ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode) 
          : const SizedBox(),
    );
  }
} 