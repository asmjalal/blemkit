import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../canvas_preview_mode.dart';

class BottomNavigationBarBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    // Get the items list and ensure we have at least 2 items
    List<dynamic> itemsList = node.properties['items'] as List<dynamic>? ?? [];
    
    // If we have fewer than 2 items, add default items to meet the minimum requirement
    if (itemsList.length < 2) {
      itemsList = [
        {
          'icon': {'type': 'Icon', 'properties': {'icon': 'Icons.home'}},
          'label': 'Home'
        },
        {
          'icon': {'type': 'Icon', 'properties': {'icon': 'Icons.search'}},
          'label': 'Search'
        },
      ];
    }
    
    return BottomNavigationBar(
      items: itemsList.map((item) {
        final iconWidget = safeWidget(context, item['icon'], hoveredNode) ?? const Icon(Icons.help);
        
        return BottomNavigationBarItem(
          icon: iconWidget,
          label: item['label'] as String? ?? 'Item',
        );
      }).toList(),
      currentIndex: node.properties['currentIndex'] ?? 0,
      onTap: (index) {
        if (!CanvasPreviewMode.of(context)) return;
        
        final item = itemsList[index];
        final navigateTo = item['navigateTo'];
        if (navigateTo != null) {
          final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
          try {
            final target = provider.screens.firstWhere((s) => s.id == navigateTo);
            provider.selectScreen(target);
          } catch (_) {
            // Screen might have been deleted
          }
        }
      },
      selectedItemColor: parseColor(node.properties['selectedItemColor'], context),
      unselectedItemColor: parseColor(node.properties['unselectedItemColor'], context),
      type: parseBottomNavigationBarType(node.properties['type']),
    );
  }

  BottomNavigationBarType? parseBottomNavigationBarType(dynamic value) {
    switch (value) {
      case 'fixed':
        return BottomNavigationBarType.fixed;
      case 'shifting':
        return BottomNavigationBarType.shifting;
      default:
        return null;
    }
  }
} 