import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../providers/widget_tree_provider.dart';
import '../../models/widget_node.dart';
import '../widget_context_menu/widget_context_menu.dart';

class WidgetSelectionWrapper extends StatelessWidget {
  final WidgetNode node;
  final WidgetNode? hoveredNode;
  final Widget child;
  final Function(String)? onContextMenuAction;

  const WidgetSelectionWrapper({
    super.key,
    required this.node,
    required this.hoveredNode,
    required this.child,
    this.onContextMenuAction,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    
    return Consumer<WidgetTreeProvider>(
      builder: (context, provider, _) {
        final isHovered = node.id == provider.hoveredNode?.id;
        final isSelected = provider.selectedNode?.id == node.id;
        final showBorder = isSelected || isHovered;
        final borderColor = isSelected ? Colors.deepPurple : Colors.deepPurpleAccent;
        final dashPattern = isSelected ? [6.0, 3.0] : [3.0, 3.0]; // dashed for selected, dotted for hover

        Widget bordered = showBorder
            ? DottedBorder(
                color: borderColor,
                dashPattern: dashPattern,
                borderType: BorderType.RRect,
                radius: const Radius.circular(8),
                strokeWidth: 2,
                child: child,
              )
            : child;

        return MouseRegion(
          onEnter: (_) => provider.setHoveredNode(node),
          onExit: (_) => provider.setHoveredNode(null),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              print('SelectionWrapper: Selecting widget ${node.type} with id ${node.id}');
              provider.selectNode(node);
            },
            onSecondaryTapDown: (details) {
              // First select the node, then show context menu
              provider.selectNode(node);
              WidgetContextMenu.show(
                context,
                details.globalPosition,
                widgetId: node.id,
                onAction: (action) {
                  if (onContextMenuAction != null) {
                    onContextMenuAction!(action);
                  }
                },
                canDelete: true,
                canRemove: true,
                canWrap: true,
                canDuplicate: true,
                canUndo: true,
                canRedo: true,
              );
            },
            child: bordered,
          ),
        );
      },
    );
  }
}
