import 'package:flutter/material.dart';


class SidebarTabBar extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabSelected;
  final bool isCollapsed;
  const SidebarTabBar({required this.selectedTab, required this.onTabSelected, required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'icon': Icons.widgets_outlined, 'label': 'Widgets'},
      {'icon': Icons.account_tree_outlined, 'label': 'Tree'},
      {'icon': Icons.palette_outlined, 'label': 'Theme'},
      {'icon': Icons.storage_outlined, 'label': 'Data'},
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int i = 0; i < tabs.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onTabSelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(
                    left: i == 0 ? 0 : 4,
                    right: i == tabs.length - 1 ? 0 : 4,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selectedTab == i ? const Color(0xFF6366f1) : const Color(0xFF2d3748).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tabs[i]['icon'] as IconData,
                        color: selectedTab == i ? Colors.white : const Color(0xFF94a3b8),
                        size: 20,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tabs[i]['label'] as String,
                        style: TextStyle(
                          color: selectedTab == i ? Colors.white : const Color(0xFF94a3b8),
                          fontWeight: selectedTab == i ? FontWeight.bold : FontWeight.w500,
                          fontSize: 10,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}