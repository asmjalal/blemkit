import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';

class ContainerBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    print('ContainerBuilder: Building container with properties: ${node.properties}');

    // Support both flat properties AND nested `decoration: {color, borderRadius, ...}`
    final Map<String, dynamic>? decorationMap =
        node.properties['decoration'] is Map<String, dynamic>
            ? node.properties['decoration'] as Map<String, dynamic>
            : null;

    // Color: prefer flat 'color', fall back to decoration.color
    final Color? parsedColor = parseColor(node.properties['color'], context) ??
        parseColor(decorationMap?['color'], context);

    // BorderRadius: prefer flat 'borderRadius', fall back to decoration.borderRadius
    final double? borderRadiusValue =
        parseDouble(node.properties['borderRadius']) ??
        parseDouble(decorationMap?['borderRadius']);

    // Border
    final bool hasBorder = (node.properties['borderWidth'] != null &&
        node.properties['borderWidth'] > 0);

    // Shadow
    final bool hasShadow = node.properties['shadowColor'] != null;

    final bool hasDecoration =
        borderRadiusValue != null || hasBorder || hasShadow;

    BoxDecoration? boxDecoration;
    if (hasDecoration) {
      boxDecoration = BoxDecoration(
        color: parsedColor,
        borderRadius: borderRadiusValue != null
            ? BorderRadius.circular(borderRadiusValue)
            : null,
        border: hasBorder
            ? Border.all(
                color: parseColor(node.properties['borderColor'], context) ?? Colors.black,
                width: parseDouble(node.properties['borderWidth']) ?? 1.0,
              )
            : null,
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: parseColor(node.properties['shadowColor'], context) ?? Colors.black26,
                  blurRadius: parseDouble(node.properties['shadowBlur']) ?? 0.0,
                  offset: Offset(
                    parseDouble(node.properties['shadowX']) ?? 0.0,
                    parseDouble(node.properties['shadowY']) ?? 0.0,
                  ),
                ),
              ]
            : null,
        gradient: parseGradient(node.properties['gradient'], context),
      );
    } else if (node.properties['gradient'] != null) {
      boxDecoration = BoxDecoration(
        gradient: parseGradient(node.properties['gradient'], context),
        color: parsedColor,
      );
    }

    return Container(
      color: hasDecoration ? null : parsedColor,
      padding: parseEdgeInsets(node.properties['padding']),
      margin: parseEdgeInsets(node.properties['margin']),
      height: parseDouble(node.properties['height']),
      width: parseDouble(node.properties['width']),
      decoration: boxDecoration,
      child: node.children.isNotEmpty
          ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode)
          : null,
    );
  }
}
