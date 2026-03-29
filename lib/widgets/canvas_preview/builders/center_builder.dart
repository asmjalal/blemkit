import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';

class CenterBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return Center(
      child: node.children.isNotEmpty 
          ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode) 
          : null,
    );
  }
} 