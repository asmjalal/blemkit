import 'package:flutter/material.dart';

import '../../ui/editor_theme.dart';

class SidebarTabBar extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabSelected;
  final bool isCollapsed;
  const SidebarTabBar({super.key, required this.selectedTab, required this.onTabSelected, required this.isCollapsed});

  static const _tabs = [
    (Icons.widgets_outlined, 'Widgets'),
    (Icons.account_tree_outlined, 'Tree'),
    (Icons.web_stories_outlined, 'Pages'),
    (Icons.palette_outlined, 'Theme'),
    (Icons.storage_outlined, 'Data'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: EditorColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: EditorColors.border),
        ),
        child: Row(
          children: [
            for (int i = 0; i < _tabs.length; i++)
              Expanded(
                child: Tooltip(
                  message: _tabs[i].$2,
                  waitDuration: const Duration(milliseconds: 600),
                  child: Material(
                    color: selectedTab == i ? EditorColors.surfaceHover : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => onTabSelected(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_tabs[i].$1, size: 17, color: selectedTab == i ? EditorColors.accent : EditorColors.textMuted),
                            const SizedBox(height: 3),
                            Text(
                              _tabs[i].$2,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: selectedTab == i ? FontWeight.w700 : FontWeight.w500,
                                color: selectedTab == i ? EditorColors.text : EditorColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
