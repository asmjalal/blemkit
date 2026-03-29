import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class ImageBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return Image.network(
      node.properties['src'] ?? '',
      width: node.properties['width']?.toDouble(),
      height: node.properties['height']?.toDouble(),
      fit: parseBoxFit(node.properties['fit']),
    );
  }
} 