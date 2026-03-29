import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';

class GridViewBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    // Check if we should use GridView.builder or regular GridView
    if (node.properties.containsKey('itemCount') && node.children.length <= 1) {
      // Use GridView.builder for dynamic grids
      return GridView.builder(
        itemCount: node.properties['itemCount'] ?? 10,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: (node.properties['crossAxisCount'] as num?)?.toInt() ?? 2,
          mainAxisSpacing: (node.properties['mainAxisSpacing'] as num?)?.toDouble() ?? 0.0,
          crossAxisSpacing: (node.properties['crossAxisSpacing'] as num?)?.toDouble() ?? 0.0,
          childAspectRatio: (node.properties['childAspectRatio'] as num?)?.toDouble() ?? 1.0,
        ),
        itemBuilder: (context, index) => node.children.isNotEmpty 
            ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode) 
            : const SizedBox(),
        scrollDirection: parseAxis(node.properties['scrollDirection']) ?? Axis.vertical,
        padding: parseEdgeInsets(node.properties['padding']),
        shrinkWrap: node.properties['shrinkWrap'] ?? false,
        physics: node.properties['physics'] == 'NeverScrollableScrollPhysics'
            ? const NeverScrollableScrollPhysics()
            : null,
      );
    } else {
      // Use regular GridView for static grids with multiple different children
      return GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: (node.properties['crossAxisCount'] as num?)?.toInt() ?? 2,
          mainAxisSpacing: (node.properties['mainAxisSpacing'] as num?)?.toDouble() ?? 0.0,
          crossAxisSpacing: (node.properties['crossAxisSpacing'] as num?)?.toDouble() ?? 0.0,
          childAspectRatio: (node.properties['childAspectRatio'] as num?)?.toDouble() ?? 1.0,
        ),
        scrollDirection: parseAxis(node.properties['scrollDirection']) ?? Axis.vertical,
        padding: parseEdgeInsets(node.properties['padding']),
        shrinkWrap: node.properties['shrinkWrap'] ?? false,
        physics: node.properties['physics'] == 'NeverScrollableScrollPhysics'
            ? const NeverScrollableScrollPhysics()
            : null,
        children: node.children
            .map((child) => WidgetBuilderFactory.buildWidget(context, child, hoveredNode))
            .toList(),
      );
    }
  }
} 