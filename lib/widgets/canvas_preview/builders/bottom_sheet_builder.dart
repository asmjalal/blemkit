import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class BottomSheetBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    // BottomSheet is typically shown using showModalBottomSheet or Scaffold.showBottomSheet.
    // Here we'll return a placeholder for the content.
    return Container(
      color: Colors.blueAccent.withOpacity(0.3),
      child: node.children.isNotEmpty
          ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode)
          : const Center(
              child: Text('BottomSheet Content Placeholder'),
            ),
    );
  }


} 