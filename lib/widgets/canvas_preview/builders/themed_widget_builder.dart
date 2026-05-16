import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/widget_node.dart';
import '../../../providers/widget_tree_provider.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';

class ThemedWidgetBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    print('ThemedWidgetBuilder: Building custom themed widget');
    
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    final String? themedId = node.properties['themedWidgetId'];
    
    if (themedId == null) {
      return const Center(child: Text('Invalid Themed Widget ID'));
    }
    
    final themedWidgetDef = provider.themedWidgets.firstWhere(
      (w) => w['id'] == themedId,
      orElse: () => {},
    );
    
    if (themedWidgetDef.isEmpty) {
      return const Center(child: Text('Themed Widget not found'));
    }
    
    // Create a temporary WidgetNode that mimics the target widget type with the stored theme properties
    final baseType = themedWidgetDef['type'] ?? 'Container';
    final properties = Map<String, dynamic>.from(themedWidgetDef['properties'] ?? {});
    
    // Add design tokens context
    final theme = provider.themeProperties;
    
    // Resolve colors if they are tokens
    properties.forEach((key, value) {
      if (key.contains('Color') && value is String && theme.containsKey(value)) {
        // We leave it as is if we want the underlying builder to resolve it using the enhanced ColorUtils
        // or we can resolve it here. For consistency with live updates, it's better if the
        // underlying builder resolves it using context-aware ColorUtils.
      }
    });

    final virtualNode = WidgetNode(
      type: baseType,
      properties: properties,
      children: node.children, // Themed widgets can wrap children
    );
    
    // We bypass the factory and call the builder directly to avoid infinite recursion or selection wrapping issues
    // because this is already inside buildWidget which will wrap it.
    // However, buildWidget is better because it handles all logic.
    // To avoid recursion, we must be careful.
    
    // Actually, we want to RENDER the base type but with these properties.
    return WidgetBuilderFactory.buildBaseWidget(context, virtualNode, hoveredNode);
  }
}
