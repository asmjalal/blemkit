import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';

class FloatingActionButtonBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    Widget? childWidget;
    final dynamic childProperty = node.properties['child'];

    if (childProperty is Map<String, dynamic>) {
      try {
        final WidgetNode childNode = WidgetNode.fromJson(childProperty);
        childWidget = WidgetBuilderFactory.buildWidget(context, childNode, hoveredNode);
      } catch (e) {
        print('FloatingActionButtonBuilder: Error building child from Map: $e. Falling back to default icon.');
        childWidget = const Icon(Icons.error); // Fallback for invalid child node
      }
    }

    return FloatingActionButton(
      onPressed: () {}, // Default empty onPressed
      backgroundColor: parseColor(node.properties['backgroundColor']),
      foregroundColor: parseColor(node.properties['foregroundColor']),
      elevation: parseDouble(node.properties['elevation']),
      child: childWidget, // Assign the built child widget
    );
  }
} 