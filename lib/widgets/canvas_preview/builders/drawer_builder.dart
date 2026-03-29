import 'package:flutter/material.dart';
import 'package:designflutterkit/models/widget_node.dart';
import 'package:designflutterkit/widgets/canvas_preview/builders/base_widget_builder.dart';
import 'package:designflutterkit/widgets/canvas_preview/builders/widget_builder_factory.dart';

class DrawerBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    final double elevation = (node.properties['elevation'] as num?)?.toDouble() ?? 16.0;

    Widget? childWidget;
    if (node.properties['child'] is Map<String, dynamic>) {
      try {
        final WidgetNode childNode = WidgetNode.fromJson(node.properties['child']);
        childWidget = WidgetBuilderFactory.buildWidget(context, childNode, hoveredNode);
      } catch (e) {
        print('Error building child for Drawer: $e');
      }
    } else if (node.children.isNotEmpty) {
      // Fallback to direct children if child property is not a map
      childWidget = WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode);
    }

    return Drawer(
      elevation: elevation,
      child: childWidget,
    );
  }
} 