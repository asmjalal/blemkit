import 'package:flutter/material.dart';
import '../../ui/editor_theme.dart';
import 'canvas_preview_mode.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../providers/widget_tree_provider.dart';
import '../../models/widget_node.dart';
import '../widget_context_menu/widget_context_menu.dart';
import '../widget_context_menu/widget_context_menu_actions.dart';

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
    // In Test mode taps belong to the app, not to selection.
    if (CanvasPreviewMode.of(context)) return child;
    
    return Consumer<WidgetTreeProvider>(
      builder: (context, provider, _) {
        final isHovered = node.id == provider.hoveredNode?.id;
        final isSelected = provider.selectedNode?.id == node.id;
        final showBorder = isSelected || isHovered;
        final borderColor = isSelected ? EditorColors.selection : EditorColors.hover;
        final borderWidth = isSelected ? 2.0 : 1.0;

        Widget bordered = showBorder
            ? DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: borderColor,
                    width: borderWidth,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                position: DecorationPosition.foreground,
                child: child,
              )
            : child;

        return MouseRegion(
          onEnter: (_) => provider.setHoveredNode(node),
          onExit: (_) => provider.setHoveredNode(null),
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (event) {
              // Use raw pointer events so selection still works even when
              // child widgets (InkWell, Button, Slider, etc.) win the gesture arena.
              if (event.buttons == kPrimaryMouseButton || event.buttons == 0) {
                final beforeId = provider.selectedNode?.id;
                // If a deeper widget also handles this pointer down, it will likely
                // select itself during the same dispatch. We only select this node
                // if nothing else changed selection by the end of this event.
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
                        // Also delete for now, or implement RemoveWidgetAction
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

