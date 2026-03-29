import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class FittedBoxBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return FittedBox(
      fit: parseBoxFit(node.properties['fit']) ?? BoxFit.contain,
      alignment: parseAlignment(node.properties['alignment']) ?? Alignment.center,
      child: node.children.isNotEmpty ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode) : null,
    );
  }


} 