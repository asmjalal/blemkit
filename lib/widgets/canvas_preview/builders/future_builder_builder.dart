import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class FutureBuilderBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return FutureBuilder(
      future: Future.value(true), // Placeholder future
      builder: (context, snapshot) {
        if (node.children.isNotEmpty) {
          return WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode);
        } else {
          return Container(
            color: Colors.blueGrey.withOpacity(0.3),
            child: const Center(child: Text('FutureBuilder Placeholder')),
          );
        }
      },
    );
  }


} 