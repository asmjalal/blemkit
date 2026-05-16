import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../providers/widget_tree_provider.dart';
import '../../models/widget_node.dart';
import '../widget_context_menu/widget_context_menu.dart';
import '../widget_context_menu/widget_context_menu_actions.dart';
import 'package:flutter/gestures.dart';

class SelectionPreferredSizeWrapper extends StatelessWidget implements PreferredSizeWidget {
  final WidgetNode node;
  final WidgetNode? hoveredNode;
  final PreferredSizeWidget child;
  final Function(String)? onContextMenuAction;

  const SelectionPreferredSizeWrapper({
    super.key,
    required this.node,
    required this.hoveredNode,
    required this.child,
    this.onContextMenuAction,
  });

  @override
  Size get preferredSize => child.preferredSize;

  @override
  Widget build(BuildContext context) {
    return Consumer<WidgetTreeProvider>(
      builder: (context, provider, _) {
        final isHovered = node.id == provider.hoveredNode?.id;
        final isSelected = provider.selectedNode?.id == node.id;
        final showBorder = isSelected || isHovered;
        final borderColor = isSelected ? Colors.deepPurple : Colors.deepPurpleAccent;
        final dashPattern = isSelected ? [6.0, 3.0] : [3.0, 3.0];

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
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (event) {
              if (event.buttons == kPrimaryMouseButton || event.buttons == 0) {
                final beforeId = provider.selectedNode?.id;
                Future.microtask(() {
                  if (provider.selectedNode?.id == beforeId) {
                    provider.selectNode(node);
                  }
                });
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
            onSecondaryTapDown: (details) {
              provider.selectNode(node);
              WidgetContextMenu.show(
                context,
                details.globalPosition,
                widgetId: node.id,
                onAction: (action) {
                  final root = provider.rootNode;
                  if (root == null) return;
                  
                  if (action.startsWith('wrap_')) {
                    final wrapperType = action.substring('wrap_'.length);
                    provider.commandManager.executeAction(
                      WrapWidgetAction(
                        node: node,
                        provider: provider,
                        root: root,
                        wrapperType: wrapperType,
                      ),
                    );
                    return;
                  }

                  switch (action) {
                    case 'duplicate':
                      provider.commandManager.executeAction(
                        DuplicateWidgetAction(node: node, provider: provider, root: root),
                      );
                      break;
                    case 'delete':
                      provider.commandManager.executeAction(
                        DeleteWidgetAction(node: node, provider: provider, root: root),
                      );
                      break;
                    case 'remove':
                      provider.commandManager.executeAction(
                        DeleteWidgetAction(node: node, provider: provider, root: root),
                      );
                      break;
                    case 'undo':
                      provider.commandManager.undo();
                      break;
                    case 'redo':
                      provider.commandManager.redo();
                      break;
                    default:
                      if (onContextMenuAction != null) {
                        onContextMenuAction!(action);
                      }
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
          ),
        );
      },
    );
  }
}
