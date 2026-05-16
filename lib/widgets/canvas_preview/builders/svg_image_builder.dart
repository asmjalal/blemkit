import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';
import '../../../utils/color_utils.dart';

class SvgImageBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    final src = node.properties['src']?.toString() ?? 'assets/icons/placeholder.svg';
    final width = (node.properties['width'] as num?)?.toDouble();
    final height = (node.properties['height'] as num?)?.toDouble();
    final color = parseColor(node.properties['color'], context);
    
    Widget svgWidget;
    
    if (src.startsWith('http')) {
      svgWidget = SvgPicture.network(
        src,
        width: width,
        height: height,
        colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
        placeholderBuilder: (context) => const CircularProgressIndicator(),
      );
    } else {
      try {
        svgWidget = SvgPicture.asset(
          src,
          width: width,
          height: height,
          colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
        );
      } catch (e) {
        svgWidget = Container(
          width: width ?? 50,
          height: height ?? 50,
          color: Colors.grey,
          child: const Center(child: Icon(Icons.broken_image)),
        );
      }
    }

    return svgWidget;
  }
}
