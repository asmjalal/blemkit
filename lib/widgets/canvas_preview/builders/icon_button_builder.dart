import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';

class IconButtonBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    Widget? iconWidget;
    final dynamic iconProperty = node.properties['icon'];

    if (iconProperty is String) {
      iconWidget = Icon(parseIconData(iconProperty) ?? Icons.help);
    } else if (iconProperty is Map<String, dynamic>) {
      try {
        final WidgetNode iconNode = WidgetNode.fromJson(iconProperty);
        iconWidget = WidgetBuilderFactory.buildWidget(context, iconNode, hoveredNode);
      } catch (e) {
        print('IconButtonBuilder: Error building icon from Map: $e. Falling back to default icon.');
        iconWidget = const Icon(Icons.error); // Fallback for invalid icon node
      }
    } else {
      iconWidget = const Icon(Icons.help); // Default fallback
    }

    return IconButton(
      icon: iconWidget!,
      onPressed: () {},
      iconSize: parseDouble(node.properties['size']),
      color: parseColor(node.properties['color']),
    );
  }
} 