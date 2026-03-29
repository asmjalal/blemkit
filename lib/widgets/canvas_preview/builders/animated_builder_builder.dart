import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class AnimatedBuilderBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return AnimatedBuilder(
      animation: const AlwaysStoppedAnimation(0.0), // Placeholder animation
      builder: (context, child) {
        if (node.children.isNotEmpty) {
          return WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode);
        } else {
          return Container(
            color: Colors.pink.withOpacity(0.3),
            child: const Center(child: Text('AnimatedBuilder Placeholder')),
          );
        }
      },
    );
  }


} 