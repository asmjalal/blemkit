import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class TextButtonBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        foregroundColor: parseColor(node.properties['foregroundColor']),
        padding: parseEdgeInsets(node.properties['padding']),
      ),
      child: node.children.isNotEmpty ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode) : const SizedBox(),
    );
  }


} 