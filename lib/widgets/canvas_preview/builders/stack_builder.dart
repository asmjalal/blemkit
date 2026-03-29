import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class StackBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return Stack(
      alignment: parseAlignment(node.properties['alignment']) ?? Alignment.topLeft,
      children: node.children.map((child) => WidgetBuilderFactory.buildWidget(context, child, hoveredNode)).toList(),
    );
  }


} 