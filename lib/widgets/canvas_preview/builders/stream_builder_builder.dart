import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class StreamBuilderBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return StreamBuilder(
      stream: Stream.value(true), // Placeholder stream
      builder: (context, snapshot) {
        if (node.children.isNotEmpty) {
          return WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode);
        } else {
          return Container(
            color: Colors.cyan.withOpacity(0.3),
            child: const Center(child: Text('StreamBuilder Placeholder')),
          );
        }
      },
    );
  }


} 