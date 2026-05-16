import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return CarouselSlider(
      options: CarouselOptions(
        height: (node.properties['height'] as num?)?.toDouble() ?? 200.0,
        autoPlay: node.properties['autoPlay'] ?? false,
        viewportFraction: (node.properties['viewportFraction'] as num?)?.toDouble() ?? 0.8,
      ),
      items: node.children.map((child) => WidgetBuilderFactory.buildWidget(context, child, hoveredNode)).toList(),
    );
  }
}
