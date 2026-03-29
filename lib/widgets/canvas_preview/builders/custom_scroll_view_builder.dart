import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class CustomScrollViewBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return CustomScrollView(
      scrollDirection: parseAxis(node.properties['scrollDirection']) ?? Axis.vertical,
      slivers: node.children.map((child) => _buildSliverFromNode(child, hoveredNode)).toList(),
    );
  }

  Widget _buildSliverFromNode(WidgetNode node, WidgetNode? hoveredNode) {
    // This is a placeholder for building slivers. In a real implementation,
    // you would have separate sliver builders.
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.green.withOpacity(0.3),
        child: Center(
          child: Text('Sliver Placeholder: ${node.type}'),
        ),
      ),
    );
  }
} 