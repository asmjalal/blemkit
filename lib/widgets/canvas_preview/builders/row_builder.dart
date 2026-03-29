import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';

class RowBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    // Check if any children are Expanded widgets
    bool hasExpandedChildren = node.children.any((child) => child.type == 'Expanded');
    
    // If we have Expanded children and no explicit mainAxisSize is set, use min to avoid conflicts
    MainAxisSize defaultMainAxisSize = hasExpandedChildren ? MainAxisSize.min : MainAxisSize.max;
    
    // Build children, converting Expanded to Flexible when in scrollable context
    List<Widget> children = node.children.map((child) {
      if (child.type == 'Expanded' && hasExpandedChildren) {
        // Convert Expanded to Flexible with loose fit to avoid conflicts in scrollable widgets
        return Flexible(
          flex: child.properties['flex'] ?? 1,
          fit: FlexFit.loose,
          child: child.children.isNotEmpty 
              ? WidgetBuilderFactory.buildWidget(context, child.children.first, hoveredNode) 
              : const SizedBox(),
        );
      } else {
        return WidgetBuilderFactory.buildWidget(context, child, hoveredNode);
      }
    }).toList();
    
    return Row(
      mainAxisAlignment: parseMainAxisAlignment(node.properties['mainAxisAlignment']) ?? MainAxisAlignment.start,
      crossAxisAlignment: parseCrossAxisAlignment(node.properties['crossAxisAlignment']) ?? CrossAxisAlignment.center,
      mainAxisSize: parseMainAxisSize(node.properties['mainAxisSize']) ?? defaultMainAxisSize,
      children: children,
    );
  }
} 