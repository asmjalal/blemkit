import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class ReorderableListViewBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return ReorderableListView(
      onReorder: (int oldIndex, int newIndex) {},
      children: node.children.map((child) {
        // ReorderableListView children need a Key
        return WidgetBuilderFactory.buildWidget(context, child, hoveredNode) ?? Container(key: UniqueKey());
      }).toList(),
      shrinkWrap: node.properties['shrinkWrap'] ?? false,
      padding: parseEdgeInsets(node.properties['padding']),
    );
  }


} 