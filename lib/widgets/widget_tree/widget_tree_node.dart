// SPDX-License-Identifier: MIT
import 'dart:ui';

import 'package:designflutterkit/widgets/widget_tree/widget_tree_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/widget_node.dart';
import '../../providers/widget_tree_provider.dart';
import '../custom_overlay_menu/custom_overlay_menu.dart';
import '../widget_context_menu/widget_context_menu.dart';
import '../widget_context_menu/widget_command_manager.dart';
import '../widget_context_menu/widget_context_menu_actions.dart';

class WidgetTreeNode extends StatefulWidget {
  final WidgetNode node;
  final WidgetNode? selectedNode;
  final void Function(WidgetNode) onSelect;
  final void Function(WidgetNode parent) onAdd;
  final void Function(WidgetNode) onDelete;
  final void Function(WidgetNode) onDuplicate;
  final Map<String, bool> expanded;
  final String search;
  final int depth;
  final String? slotLabel;

  const WidgetTreeNode({
    required this.node,
    required this.selectedNode,
    required this.onSelect,
    required this.onAdd,
    required this.onDelete,
    required this.onDuplicate,
    required this.expanded,
    required this.search,
    required this.depth,
    this.slotLabel,
  });

  @override
  State<WidgetTreeNode> createState() => WidgetTreeNodeState();
}

class WidgetTreeNodeState extends State<WidgetTreeNode> {
  bool get isExpanded => widget.expanded[widget.node.id] ?? true;
  WidgetNode? _draggedNode;

  bool get isChildrenList => _acceptsMultipleChildren(widget.node.type);
  bool get isChildSlot => !isChildrenList;
  bool get hasSlotMap => _slotMapForType(widget.node.type).isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.selectedNode == widget.node;
    final hasChildren = widget.node.children.isNotEmpty;
    final matchesSearch = widget.search.isEmpty ||
        widget.node.type.toLowerCase().contains(widget.search) ||
        (widget.node.properties['text']?.toString().toLowerCase().contains(widget.search) ?? false);
    if (!matchesSearch) return const SizedBox.shrink();

    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);

    List<Widget> childrenWidgets = [];
    if (isChildrenList) {
      for (int i = 0; i < widget.node.children.length; i++) {
        // Drop target before each child
        childrenWidgets.add(_DropTarget(
          onAccept: (dragged) {
            if (dragged != widget.node.children[i] && !_isDescendant(dragged, widget.node.children[i])) {
              final oldParent = _findParent(provider.rootNode, dragged);
              if (oldParent == widget.node) {
                final oldIndex = widget.node.children.indexOf(dragged);
                int newIndex = i;
                if (oldIndex < newIndex) newIndex--;
                provider.reorderNode(widget.node, oldIndex, newIndex);
              } else {
                provider.moveNode(dragged, widget.node, newIndex: i);
              }
              provider.selectNode(dragged);
            }
          },
          canAccept: (dragged) => dragged != widget.node.children[i] && !_isDescendant(dragged, widget.node.children[i]),
        ));
        // The child node itself
        childrenWidgets.add(WidgetTreeNode(
          node: widget.node.children[i],
          selectedNode: widget.selectedNode,
          onSelect: widget.onSelect,
          onAdd: widget.onAdd,
          onDelete: widget.onDelete,
          onDuplicate: widget.onDuplicate,
          expanded: widget.expanded,
          search: widget.search,
          depth: widget.depth + 1,
        ));
      }
      // Drop target at the end of the list
      childrenWidgets.add(_DropTarget(
        onAccept: (dragged) {
          if (!_isDescendant(dragged, widget.node)) {
            provider.moveNode(dragged, widget.node);
            provider.selectNode(dragged);
          }
        },
        canAccept: (dragged) => !_isDescendant(dragged, widget.node),
      ));
    } else if (widget.node.children.isNotEmpty) {
      // Single child slot (e.g., widgets that accept exactly one child)
      childrenWidgets.add(_DropTarget(
        onAccept: (dragged) {
          if (!_isDescendant(dragged, widget.node)) {
            widget.node.properties[widget.node.children.first.type] = dragged;
            provider.notifyListeners();
            provider.selectNode(dragged);
          }
        },
        canAccept: (dragged) => !_isDescendant(dragged, widget.node),
        child: WidgetTreeNode(
          node: widget.node.children.first,
          selectedNode: widget.selectedNode,
          onSelect: widget.onSelect,
          onAdd: widget.onAdd,
          onDelete: widget.onDelete,
          onDuplicate: widget.onDuplicate,
          expanded: widget.expanded,
          search: widget.search,
          depth: widget.depth + 1,
        ),
      ));
    } else if (hasSlotMap) {
      // Handle named slots for widgets like ListTile, AppBar, etc.
      final slotMap = _slotMapForType(widget.node.type);
      slotMap.forEach((slotKey, slotLabel) {
        final prop = widget.node.properties[slotKey];
        if (prop is WidgetNode) {
          // Existing widget in slot – render it with a drop target.
          childrenWidgets.add(_DropTarget(
            onAccept: (dragged) {
              if (!_isDescendant(dragged, widget.node)) {
                widget.node.properties[slotKey] = dragged;
                provider.notifyListeners();
                provider.selectNode(dragged);
              }
            },
            canAccept: (dragged) => !_isDescendant(dragged, widget.node),
            child: WidgetTreeNode(
              node: prop,
              selectedNode: widget.selectedNode,
              onSelect: widget.onSelect,
              onAdd: widget.onAdd,
              onDelete: widget.onDelete,
              onDuplicate: widget.onDuplicate,
              expanded: widget.expanded,
              search: widget.search,
              depth: widget.depth + 1,
              slotLabel: slotLabel,
            ),
          ));
        } else {
          // Empty/primitive slot – render placeholder node and allow dropping a widget.
          childrenWidgets.add(_DropTarget(
            onAccept: (dragged) {
              if (!_isDescendant(dragged, widget.node)) {
                widget.node.properties[slotKey] = dragged;
                provider.notifyListeners();
                provider.selectNode(dragged);
              }
            },
            canAccept: (dragged) => !_isDescendant(dragged, widget.node),
            child: WidgetTreeNodePlaceholder(
              slotKey: slotKey,
              slotLabel: slotLabel,
              parentNode: widget.node,
              depth: widget.depth + 1,
            ),
          ));
        }
      });
    } else {
      // Fallback generic slot handling for widgets without a slot map.
      childrenWidgets.add(_DropTarget(
        onAccept: (dragged) {
          if (!_isDescendant(dragged, widget.node)) {
            provider.addChild(widget.node, dragged);
            provider.selectNode(dragged);
          }
        },
        canAccept: (dragged) => !_isDescendant(dragged, widget.node),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LongPressDraggable<WidgetNode>(
          data: widget.node,
          feedback: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _widgetIcon(widget.node.type),
                  const SizedBox(width: 8),
                  Text(_widgetLabel(widget.node)),
                ],
              ),
            ),
          ),
          child: Listener(
            onPointerDown: (event) {
              if (event.kind == PointerDeviceKind.mouse && event.buttons == 2) {
                // Right‑click suppression (handled elsewhere)
              }
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => provider.setHoveredNode(widget.node),
              onExit: (_) => provider.setHoveredNode(null),
              child: GestureDetector(
                onTap: () => widget.onSelect(widget.node),
                onSecondaryTapDown: (details) {
                  WidgetContextMenu.show(
                    context,
                    details.globalPosition,
                    widgetId: widget.node.id,
                    onAction: (action) {
                      final root = provider.rootNode!;
                      if (action.startsWith('wrap_')) {
                        final wrapperType = action.substring('wrap_'.length);
                        provider.commandManager.executeAction(
                          WrapWidgetAction(
                            node: widget.node,
                            provider: provider,
                            root: root,
                            wrapperType: wrapperType,
                          ),
                        );
                        return;
                      }
                      switch (action) {
                        case 'duplicate':
                          widget.onDuplicate(widget.node);
                          break;
                        case 'delete':
                          provider.commandManager.executeAction(
                            DeleteWidgetAction(node: widget.node, provider: provider, root: root),
                          );
                          break;
                        case 'undo':
                          provider.commandManager.undo();
                          break;
                        case 'redo':
                          provider.commandManager.redo();
                          break;
                      }
                    },
                    canDelete: widget.node.type != 'Scaffold',
                  );
                },
                child: Consumer<WidgetTreeProvider>(
                  builder: (context, provider, _) {
                    final isHovered = provider.hoveredNode == widget.node;
                    final isSelected = widget.selectedNode == widget.node;
                    return Container(
                      margin: EdgeInsets.only(left: widget.depth * 20.0, top: 2, bottom: 2, right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.deepPurple.withOpacity(0.08)
                            : isHovered
                                ? Colors.deepPurple.withOpacity(0.04)
                                : null,
                        border: isHovered && !isSelected
                            ? Border.all(color: Colors.deepPurpleAccent, width: 1.5)
                            : null,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          if ((isChildrenList && widget.node.children.isNotEmpty) || hasSlotMap)
                            SizedBox(
                              width: 32,
                              child: IconButton(
                                icon: Icon(isExpanded ? Icons.expand_more : Icons.chevron_right, size: 18),
                                onPressed: () {
                                  setState(() {
                                    widget.expanded[widget.node.id] = !isExpanded;
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            )
                          else
                            const SizedBox(width: 32),
                          _widgetIcon(widget.node.type),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _widgetLabel(widget.node),
                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 28,
                            child: IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: () => widget.onAdd(widget.node),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: 'Add child widget',
                            ),
                          ),
                          SizedBox(
                            width: 28,
                            child: IconButton(
                              icon: const Icon(Icons.delete, size: 16),
                              onPressed: () => widget.onDelete(widget.node),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: 'Delete widget',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        if (isExpanded) ...childrenWidgets,
      ],
    );
  }

  bool _acceptsMultipleChildren(String type) {
    const multiple = [
      'Row', 'Column', 'Stack', 'Wrap', 'ListView', 'GridView', 'SingleChildScrollView',
      'Scaffold', 'AppBar', 'BottomNavigationBar', 'Form', 'CustomScrollView',
      'ReorderableListView', 'PageView', 'TabBarView', 'ExpansionTile', 'Drawer',
      'Card', 'Container', 'Center', 'Padding', 'Expanded', 'Flexible', 'SizedBox',
      'Positioned', 'Align', 'InkWell', 'GestureDetector', 'ElevatedButton', 'TextButton',
      'OutlinedButton', 'IconButton', 'FloatingActionButton', 'Chip',
      'CircleAvatar', 'Tooltip', 'AlertDialog', 'BottomSheet',
    ];
    return multiple.contains(type);
  }

  Map<String, String> _slotMapForType(String type) {
    switch (type) {
      case 'ListTile':
        return {
          'leading': 'Leading',
          'title': 'Title',
          'subtitle': 'Subtitle',
          'trailing': 'Trailing',
        };
      default:
        return {};
    }
  }

  WidgetNode? _findParent(WidgetNode? root, WidgetNode child) {
    if (root == null) return null;
    if (root.children.contains(child)) return root;
    for (final c in root.children) {
      final found = _findParent(c, child);
      if (found != null) return found;
    }
    return null;
  }

  bool _isDescendant(WidgetNode? parent, WidgetNode child) {
    if (parent == null) return false;
    if (parent.children.contains(child)) return true;
    for (final c in parent.children) {
      if (_isDescendant(c, child)) return true;
    }
    return false;
  }

  Widget _widgetIcon(String type) {
    switch (type) {
      case 'Container':
        return const Icon(Icons.crop_square, size: 18);
      case 'Row':
        return const Icon(Icons.view_column, size: 18);
      case 'Column':
        return const Icon(Icons.view_agenda, size: 18);
      case 'Text':
        return const Icon(Icons.text_fields, size: 18);
      case 'ElevatedButton':
      case 'TextButton':
      case 'OutlinedButton':
        return const Icon(Icons.smart_button, size: 18);
      case 'TextField':
        return const Icon(Icons.input, size: 18);
      case 'Icon':
        return const Icon(Icons.star, size: 18);
      case 'Image':
        return const Icon(Icons.image, size: 18);
      case 'Card':
        return const Icon(Icons.credit_card, size: 18);
      case 'ListView':
        return const Icon(Icons.list, size: 18);
      case 'GridView':
        return const Icon(Icons.grid_view, size: 18);
      case 'Scaffold':
        return const Icon(Icons.web_asset, size: 18);
      case 'AppBar':
        return const Icon(Icons.web_asset_outlined, size: 18);
      case 'SingleChildScrollView':
        return const Icon(Icons.rotate_left, size: 18);
      case 'Center':
        return const Icon(Icons.center_focus_strong, size: 18);
      case 'Padding':
        return const Icon(Icons.space_bar, size: 18);
      case 'SizedBox':
        return const Icon(Icons.crop_din, size: 18);
      case 'Expanded':
      case 'Flexible':
        return const Icon(Icons.open_in_full, size: 18);
      case 'IconButton':
        return const Icon(Icons.radio_button_checked, size: 18);
      case 'FloatingActionButton':
        return const Icon(Icons.add_circle, size: 18);
      case 'BottomNavigationBar':
        return const Icon(Icons.roundabout_right, size: 18);
      default:
        return const Icon(Icons.widgets, size: 18);
    }
  }

  String _widgetLabel(WidgetNode node) {
    final baseLabel = _widgetBaseLabel(node);
    if (widget.slotLabel != null) {
      return '${widget.slotLabel}: $baseLabel';
    }
    return baseLabel;
  }

  String _widgetBaseLabel(WidgetNode node) {
    switch (node.type) {
      case 'Text':
        if (node.properties['text'] != null) {
          String text = node.properties['text'].toString();
          if (text.length > 20) text = '${text.substring(0, 20)}...';
          return 'Text: "$text"';
        }
        return 'Text';
      case 'Container':
        List<String> props = [];
        if (node.properties['width'] != null) props.add('w:${node.properties['width']}');
        if (node.properties['height'] != null) props.add('h:${node.properties['height']}');
        if (node.properties['color'] != null && node.properties['color'] != Colors.transparent.value.toString()) {
          props.add('colored');
        }
        if (props.isNotEmpty && props.length <= 2) {
          return 'Container (${props.join(', ')})';
        } else if (props.length > 2) {
          return 'Container (${props.length} props)';
        }
        return 'Container';
      case 'Icon':
        if (node.properties['icon'] != null) {
          String icon = node.properties['icon'].toString();
          if (icon.startsWith('Icons.')) icon = icon.substring(6);
          return 'Icon: $icon';
        }
        return 'Icon';
      case 'ElevatedButton':
      case 'TextButton':
      case 'OutlinedButton':
        return '${node.type} (${node.children.length} child${node.children.length != 1 ? 'ren' : ''})';
      case 'ListView':
        String direction = node.properties['scrollDirection'] == 'horizontal' ? ' (horizontal)' : '';
        return 'ListView$direction (${node.children.length} items)';
      case 'GridView':
        int crossAxisCount = node.properties['crossAxisCount'] ?? 2;
        return 'GridView (${crossAxisCount}x${node.children.length ~/ crossAxisCount})';
      case 'Scaffold':
        String className = node.properties['className']?.toString() ?? '';
        if (className.isNotEmpty) {
          return 'Screen: $className';
        }
        return 'Screen';
      case 'Column':
      case 'Row':
        return '${node.type} (${node.children.length} children)';
      default:
        if (node.children.isNotEmpty) {
          return '${node.type} (${node.children.length} child${node.children.length != 1 ? 'ren' : ''})';
        }
        return node.type;
    }
  }
}

class _DropTarget extends StatelessWidget {
  final void Function(WidgetNode) onAccept;
  final bool Function(WidgetNode) canAccept;
  final Widget? child;

  const _DropTarget({required this.onAccept, required this.canAccept, this.child});

  @override
  Widget build(BuildContext context) {
    return DragTarget<WidgetNode>(
      onWillAccept: (data) => data != null && canAccept(data),
      onAccept: onAccept,
      builder: (context, candidateData, rejectedData) {
        return Column(
          children: [
            if (candidateData.isNotEmpty)
              Container(
                height: 6,
                color: Colors.deepPurple.withOpacity(0.2),
              ),
            if (child != null) child!,
          ],
        );
      },
    );
  }
}

class WidgetTreeNodePlaceholder extends StatelessWidget {
  final String slotKey;
  final String slotLabel;
  final WidgetNode parentNode;
  final int depth;

  const WidgetTreeNodePlaceholder({
    Key? key,
    required this.slotKey,
    required this.slotLabel,
    required this.parentNode,
    required this.depth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _showAddWidgetToSlotDialog(context);
        },
        child: Container(
          margin: EdgeInsets.only(left: depth * 20.0, top: 2, bottom: 2, right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white24, style: BorderStyle.solid),
          ),
          child: Row(
            children: [
              const SizedBox(width: 32), // space for expand arrow
              const Icon(Icons.add_circle_outline, size: 16, color: Colors.white30),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$slotLabel: (Empty)',
                  style: const TextStyle(color: Colors.white30, fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddWidgetToSlotDialog(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    final categories = [
      {'type': 'Text', 'icon': Icons.text_fields},
      {'type': 'Icon', 'icon': Icons.star},
      {'type': 'IconButton', 'icon': Icons.add_circle_outline},
      {'type': 'CircleAvatar', 'icon': Icons.account_circle},
      {'type': 'Chip', 'icon': Icons.tag},
    ];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: Text('Add Widget to $slotLabel', style: const TextStyle(color: Colors.white)),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final widgetInfo in categories)
                ElevatedButton.icon(
                  icon: Icon(widgetInfo['icon'] as IconData),
                  label: Text(widgetInfo['type'] as String),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade600,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final newNode = WidgetTreeEditor.createWidgetNodeWithDefaults(widgetInfo['type'] as String);
                    final properties = Map<String, dynamic>.from(parentNode.properties);
                    properties[slotKey] = newNode;
                    provider.updateNodeProperties(parentNode, properties);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}