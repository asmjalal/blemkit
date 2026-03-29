import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class PageViewBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return PageView(
      scrollDirection: parseAxis(node.properties['scrollDirection']) ?? Axis.horizontal,
      children: node.children.map((child) => WidgetBuilderFactory.buildWidget(context, child, hoveredNode)).toList(),
    );
  }


} 