import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class IconBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return Icon(
      parseIconData(node.properties['icon']),
      size: node.properties['size']?.toDouble() ?? 24.0,
      color: parseColor(node.properties['color']),
    );
  }
} 