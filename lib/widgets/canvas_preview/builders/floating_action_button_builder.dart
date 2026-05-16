import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';

class FloatingActionButtonBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    Widget? childWidget;
    final dynamic childProperty = node.properties['child'];

    if (childProperty is Map<String, dynamic>) {
      try {
        final WidgetNode childNode = WidgetNode.fromJson(childProperty);
        childWidget = WidgetBuilderFactory.buildWidget(context, childNode, hoveredNode);
      } catch (e) {
        print('FloatingActionButtonBuilder: Error building child from Map: $e. Falling back to default icon.');
        childWidget = const Icon(Icons.error); // Fallback for invalid child node
      }
    }

    return FloatingActionButton(
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
      backgroundColor: parseColor(node.properties['backgroundColor'], context),
      foregroundColor: parseColor(node.properties['foregroundColor'], context),
      elevation: parseDouble(node.properties['elevation']),
      child: childWidget, // Assign the built child widget
    );
  }
} 