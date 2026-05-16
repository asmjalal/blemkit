import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';
import '../../../utils/color_utils.dart';

class SelectableTextBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return SelectableText(
      node.properties['text']?.toString() ?? 'Selectable Text',
      textAlign: parseTextAlign(node.properties['textAlign']),
      style: TextStyle(
        color: parseColor(node.properties['color'], context),
        fontSize: (node.properties['fontSize'] as num?)?.toDouble(),
        fontWeight: parseFontWeight(node.properties['fontWeight']),
      ),
    );
  }
}
