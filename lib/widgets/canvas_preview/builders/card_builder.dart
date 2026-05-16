import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';

class CardBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    // Parse optional shape/borderRadius — ecommerce uses "shape": {"borderRadius": 16.0}
    ShapeBorder? shape;
    final shapeData = node.properties['shape'];
    if (shapeData is Map<String, dynamic> && shapeData['borderRadius'] != null) {
      final radius = (shapeData['borderRadius'] as num).toDouble();
      shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
    }

    return Card(
      color: parseColor(node.properties['color'], context),
      elevation: (node.properties['elevation'] as num?)?.toDouble(),
      margin: parseEdgeInsets(node.properties['margin']),
      shape: shape,
      child: node.children.isNotEmpty
          ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode)
          : null,
    );
  }
}