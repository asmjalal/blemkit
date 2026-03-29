import 'package:flutter/material.dart';
import '../custom_overlay_menu/custom_overlay_menu.dart';
import 'widget_context_menu_actions.dart';

class WidgetContextMenu {
  static void show(
    BuildContext context,
    Offset position, {
    required String widgetId,
    required void Function(String action) onAction,
    bool canDelete = true,
    bool canRemove = true,
    bool canWrap = true,
    bool canDuplicate = true,
    bool canUndo = true,
    bool canRedo = true,
  }) {
    final items = <CustomOverlayMenuItem>[
      if (canDuplicate)
        CustomOverlayMenuItem(
          label: 'Duplicate',
          icon: Icons.copy,
          onTap: () => onAction('duplicate'),
        ),
      if (canWrap)
        CustomOverlayMenuItem(
          label: 'Wrap Widget',
          icon: Icons.wrap_text,
          onTap: () => onAction('wrap'),
        ),
      CustomOverlayMenuItem(
        label: 'Replace Widget',
        icon: Icons.swap_horiz,
        onTap: () => onAction('replace'),
      ),
      if (canRemove)
        CustomOverlayMenuItem(
          label: 'Remove Widget',
          icon: Icons.indeterminate_check_box,
          onTap: () => onAction('remove'),
        ),
      if (canDelete)
        CustomOverlayMenuItem(
          label: 'Delete Widget',
          icon: Icons.delete,
          onTap: () => onAction('delete'),
        ),
      CustomOverlayMenuItem(
        label: 'Undo',
        icon: Icons.undo,
        onTap: () => onAction('undo'),
      ),
      CustomOverlayMenuItem(
        label: 'Redo',
        icon: Icons.redo,
        onTap: () => onAction('redo'),
      ),
    ];
    CustomOverlayMenu.show(context, position, items: items);
  }
} 