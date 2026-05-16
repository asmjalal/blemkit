import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class IconBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    final iconData = parseIconData(node.properties['icon']);
    final size = parseDouble(node.properties['size']) ?? 24.0;
    final color = parseColor(node.properties['color'], context);

    final iconString = node.properties['icon']?.toString() ?? '';
    
    if (iconString.startsWith('FontAwesomeIcons.')) {
      return FaIcon(iconData, size: size, color: color);
    } else if (iconData != null) {
      return Icon(iconData, size: size, color: color);
    }
    
    return Icon(Icons.widgets, size: size, color: color);
  }
} 