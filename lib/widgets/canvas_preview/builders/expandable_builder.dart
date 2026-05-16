import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';
import 'package:expandable/expandable.dart';

class ExpandableBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    // Expect at least two children: 0 -> header, 1 -> body (expanded)
    final children = node.children;
    Widget header = children.isNotEmpty ? WidgetBuilderFactory.buildWidget(context, children[0], hoveredNode) : const Text('Header');
    Widget expanded = children.length > 1 ? WidgetBuilderFactory.buildWidget(context, children[1], hoveredNode) : const Text('Expanded Content');

    return ExpandablePanel(
      header: header,
      collapsed: const SizedBox.shrink(),
      expanded: expanded,
      theme: ExpandableThemeData(
        hasIcon: node.properties['hasIcon'] ?? true,
        iconPlacement: node.properties['iconPlacement'] == 'left' ? ExpandablePanelIconPlacement.left : ExpandablePanelIconPlacement.right,
        iconColor: Colors.black54,
      ),
    );
  }
}
