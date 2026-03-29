import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';

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
        Widget iconWidget;
        if (item['icon'] is Map<String, dynamic>) {
          iconWidget = WidgetBuilderFactory.buildWidget(
            context, 
            WidgetNode.fromJson(item['icon']), 
            hoveredNode
          );
        } else {
          iconWidget = const Icon(Icons.help);
        }
        
        return BottomNavigationBarItem(
          icon: iconWidget,
          label: item['label'] as String? ?? 'Item',
        );
      }).toList(),
      currentIndex: node.properties['currentIndex'] ?? 0,
      onTap: (index) {},
      selectedItemColor: parseColor(node.properties['selectedItemColor']),
      unselectedItemColor: parseColor(node.properties['unselectedItemColor']),
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