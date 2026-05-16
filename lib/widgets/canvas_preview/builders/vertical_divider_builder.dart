import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import '../../../utils/color_utils.dart';

class VerticalDividerBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return VerticalDivider(
      width: (node.properties['width'] as num?)?.toDouble() ?? 16.0,
      thickness: (node.properties['thickness'] as num?)?.toDouble() ?? 1.0,
      indent: (node.properties['indent'] as num?)?.toDouble() ?? 0.0,
      endIndent: (node.properties['endIndent'] as num?)?.toDouble() ?? 0.0,
      color: parseColor(node.properties['color'], context),
    );
  }
}
