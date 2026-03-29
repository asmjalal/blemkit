import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';

class ListViewBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    // Check if we should use ListView.builder or regular ListView
    if (node.properties.containsKey('itemCount') && node.children.length <= 1) {
      // Use ListView.builder for dynamic lists
      return ListView.builder(
        itemCount: node.properties['itemCount'] ?? 10,
        itemBuilder: (context, index) => node.children.isNotEmpty 
            ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode) 
            : const SizedBox(),
        scrollDirection: parseAxis(node.properties['scrollDirection']) ?? Axis.vertical,
        padding: parseEdgeInsets(node.properties['padding']),
        shrinkWrap: node.properties['shrinkWrap'] ?? false,
      );
    } else {
      // Use regular ListView for static lists with multiple different children
      return ListView(
        scrollDirection: parseAxis(node.properties['scrollDirection']) ?? Axis.vertical,
        padding: parseEdgeInsets(node.properties['padding']),
        shrinkWrap: node.properties['shrinkWrap'] ?? false,
        children: node.children
            .map((child) => WidgetBuilderFactory.buildWidget(context, child, hoveredNode))
            .toList(),
      );
    }
  }
} 