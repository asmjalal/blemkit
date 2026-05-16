import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class TextBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    // safeString() handles String, num, and nested Map widget nodes gracefully
    final displayText = resolveDataBinding(node, node.properties['text'] ?? '');

    return Text(
      displayText,
      style: TextStyle(
        fontSize: parseDouble(node.properties['fontSize']) ?? 14.0,
        color: parseColor(node.properties['color'], context),
        fontWeight: parseFontWeight(node.properties['fontWeight']),
        fontStyle: node.properties['fontStyle'] == 'italic' ? FontStyle.italic : FontStyle.normal,
        fontFamily: node.properties['fontFamily'] is String ? node.properties['fontFamily'] as String : null,
        decoration: parseTextDecoration(node.properties['textDecoration']),
        decorationColor: parseColor(node.properties['decorationColor'], context),
        decorationStyle: parseTextDecorationStyle(node.properties['decorationStyle']),
        letterSpacing: parseDouble(node.properties['letterSpacing']),
        wordSpacing: parseDouble(node.properties['wordSpacing']),
        height: parseDouble(node.properties['height']),
        shadows: node.properties['shadowColor'] != null
            ? [
                Shadow(
                  color: parseColor(node.properties['shadowColor'], context) ?? Colors.black26,
                  blurRadius: parseDouble(node.properties['shadowBlur']) ?? 0.0,
                  offset: Offset(
                    parseDouble(node.properties['shadowX']) ?? 0.0,
                    parseDouble(node.properties['shadowY']) ?? 0.0,
                  ),
                ),
              ]
            : null,
      ),
      textAlign: parseTextAlign(node.properties['textAlign']),
      overflow: parseTextOverflow(node.properties['overflow']),
      maxLines: node.properties['maxLines'] is int ? node.properties['maxLines'] as int : null,
    );
  }
}