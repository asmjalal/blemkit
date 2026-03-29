import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class TextBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return Text(
      resolveDataBinding(node, node.properties['text'] ?? ''),
      style: TextStyle(
        fontSize: (node.properties['fontSize'] is num && node.properties['fontSize'] != null) ? node.properties['fontSize'].toDouble() : 14.0,
        color: parseColor(node.properties['color']),
        fontWeight: parseFontWeight(node.properties['fontWeight']),
        fontStyle: node.properties['fontStyle'] == 'italic' ? FontStyle.italic : FontStyle.normal,
        fontFamily: node.properties['fontFamily'] as String?,
        decoration: parseTextDecoration(node.properties['textDecoration']),
        decorationColor: parseColor(node.properties['decorationColor']),
        decorationStyle: parseTextDecorationStyle(node.properties['decorationStyle']),
        letterSpacing: node.properties['letterSpacing']?.toDouble(),
        wordSpacing: node.properties['wordSpacing']?.toDouble(),
        height: node.properties['height']?.toDouble(),
        shadows: node.properties['shadowColor'] != null
            ? [
                Shadow(
                  color: parseColor(node.properties['shadowColor']) ?? Colors.black26,
                  blurRadius: node.properties['shadowBlur']?.toDouble() ?? 0.0,
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
      maxLines: node.properties['maxLines'] as int?,
    );
  }
} 