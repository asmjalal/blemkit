import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class PopupMenuButtonBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return PopupMenuButton<String>(
      itemBuilder: (BuildContext context) {
        return (node.properties['items'] as List<dynamic>? ?? []).map((item) {
          return PopupMenuItem<String>(
            value: item['value'] as String,
            child: Text(item['label'] as String),
          );
        }).toList();
      },
      onSelected: (String result) {},
      child: node.children.isNotEmpty ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode) : null,
    );
  }


} 