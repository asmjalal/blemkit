import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class MediaQueryBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    // MediaQuery doesn't directly render a widget, but provides data.
    // We'll return a placeholder or its child if available.
    if (node.children.isNotEmpty) {
      return WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode);
    } else {
      final mediaQueryData = MediaQuery.of(context);
      return Container(
        color: Colors.lime.withOpacity(0.3),
        child: Center(
          child: Text('MediaQuery Placeholder\nSize: ${mediaQueryData.size.width.toInt()}x${mediaQueryData.size.height.toInt()}\nOrientation: ${mediaQueryData.orientation.toString().split('.').last}'),
        ),
      );
    }
  }


} 