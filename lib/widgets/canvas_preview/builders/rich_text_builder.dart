import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class RichTextBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return RichText(
      text: TextSpan(
        text: node.properties['text'] ?? '',
        style: TextStyle(
          fontSize: parseDouble(node.properties['fontSize']) ?? 14.0,
          color: parseColor(node.properties['textColor'], context),
          fontWeight: parseFontWeight(node.properties['fontWeight']),
          fontFamily: node.properties['fontFamily'] as String?,
        ),
        children: (node.properties['children'] as List? ?? []).map((child) {
          if (child is Map<String, dynamic> && child['type'] == 'TextSpan') {
            return TextSpan(
              text: child['text'] as String?,
              style: TextStyle(
                fontSize: parseDouble(child['properties']?['fontSize']) ?? 14.0,
                color: parseColor(child['properties']?['color'], context),
                fontWeight: parseFontWeight(child['properties']?['fontWeight']),
              ),
            );
          }
          return const TextSpan();
        }).toList(),
      ),
    );
  }
} 