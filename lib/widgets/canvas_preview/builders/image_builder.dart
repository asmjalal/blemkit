import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class ImageBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return Image.network(
      node.properties['src'] ?? '',
      width: parseDouble(node.properties['width']),
      height: parseDouble(node.properties['height']),
      fit: parseBoxFit(node.properties['fit']),
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: parseDouble(node.properties['width']) ?? 50.0,
          height: parseDouble(node.properties['height']) ?? 50.0,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      },
    );
  }
} 