import 'dart:async';

import 'package:flutter/material.dart';
import '../custom_overlay_menu/custom_overlay_menu.dart';

class AddMenuButton extends StatelessWidget {
  final void Function(String type) onAdd;
  final List<Map<String, dynamic>> categories;
  const AddMenuButton({required this.onAdd, required this.categories});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add, size: 18, color: Color(0xFF6366f1)),
      onPressed: () {
        final RenderBox buttonBox = context.findRenderObject() as RenderBox;
        final Offset buttonPosition = buttonBox.localToGlobal(Offset.zero);
        // Convert categories to CustomOverlayMenuItem
        List<CustomOverlayMenuItem> menuItems = [
          for (final category in categories)
            CustomOverlayMenuItem(
              label: category['name'] as String,
              icon: Icons.folder,
              submenu: [
                for (final widgetInfo in category['widgets'] as List<Map<String, dynamic>>)
                  CustomOverlayMenuItem(
                    label: widgetInfo['type'] as String,
                    icon: widgetInfo['icon'] as IconData?,
                    onTap: () {
                      onAdd(widgetInfo['type'] as String);
                    },
                  ),
              ],
            ),
        ];
        CustomOverlayMenu.show(context, buttonPosition, items: menuItems);
      },
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
} 