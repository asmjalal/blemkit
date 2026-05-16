import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';

class ButtonBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return ElevatedButton(
      onPressed: () {
        final navigateTo = node.properties['navigateTo'];
        if (navigateTo != null) {
          final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
          try {
            final target = provider.screens.firstWhere((s) => s.id == navigateTo);
            provider.selectScreen(target);
          } catch (_) {
            // Screen might have been deleted
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: parseColor(node.properties['backgroundColor'], context),
        padding: parseEdgeInsets(node.properties['padding']),
      ),
      child: node.children.isNotEmpty 
          ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode) 
          : const SizedBox(),
    );
  }
} 