import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class FlexibleBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return Flexible(
      flex: node.properties['flex'] ?? 1,
      fit: parseFlexFit(node.properties['fit']) ?? FlexFit.loose,
      child: node.children.isNotEmpty ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode) : const SizedBox(),
    );
  }



  FlexFit? parseFlexFit(dynamic value) {
    switch (value) {
      case 'loose':
        return FlexFit.loose;
      case 'tight':
        return FlexFit.tight;
      default:
        return null;
    }
  }
} 