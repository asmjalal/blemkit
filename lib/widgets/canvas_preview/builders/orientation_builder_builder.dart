import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class OrientationBuilderBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (node.children.isNotEmpty) {
          return WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode);
        } else {
          return Container(
            color: Colors.indigo.withOpacity(0.3),
            child: Center(
              child: Text('OrientationBuilder Placeholder: ${orientation.toString().split('.').last}'),
            ),
          );
        }
      },
    );
  }


} 