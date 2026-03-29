import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class LayoutBuilderBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (node.children.isNotEmpty) {
          return WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode);
        } else {
          return Container(
            color: Colors.teal.withOpacity(0.3),
            child: Center(
              child: Text('LayoutBuilder Placeholder: W: ${constraints.maxWidth.toInt()}, H: ${constraints.maxHeight.toInt()}'),
            ),
          );
        }
      },
    );
  }


} 