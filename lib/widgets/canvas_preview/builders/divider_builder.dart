import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class DividerBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return Divider(
      height: (node.properties['height'] as num?)?.toDouble(),
      thickness: (node.properties['thickness'] as num?)?.toDouble(),
      indent: (node.properties['indent'] as num?)?.toDouble(),
      endIndent: (node.properties['endIndent'] as num?)?.toDouble(),
      color: parseColor(node.properties['color']),
    );
  }
} 