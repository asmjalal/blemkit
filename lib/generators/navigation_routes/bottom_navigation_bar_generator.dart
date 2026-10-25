import '../base_widget_generator.dart';
import '../../models/widget_node.dart';
import '../widget_generator_registry.dart';
import '../project_generator.dart';

class BottomNavigationBarGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    // Handle navigation
    String onTapCode = '(index) {}';
    if (ProjectGenerator.generatingNavigationShell) {
      // In the shell, delegate to the shell's state manager
      onTapCode = '_onTabTapped';
    } else if (node.properties['items'] != null && node.properties['items'] is List) {
      final items = node.properties['items'] as List;
      final navCalls = <String>[];
      bool hasNav = false;
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        if (item is Map && item.containsKey('navigateTo')) {
          final navBody = generateNavigationBody(item['navigateTo']?.toString());
          if (navBody.isNotEmpty) {
            navCalls.add('case $i: $navBody break;');
            hasNav = true;
          }
        }
      }
      if (hasNav) {
        onTapCode = '(index) {\n$childIndentStr  switch (index) {\n$childIndentStr    ${navCalls.join('\n$childIndentStr    ')}\n$childIndentStr  }\n$childIndentStr}';
      }
    }
    
    final props = <String>[];
    final currentIndexCode = ProjectGenerator.generatingNavigationShell
        ? '_currentIndex'
        : '${node.properties['currentIndex'] ?? 0}';
    props.add('currentIndex: $currentIndexCode');
    props.add('onTap: $onTapCode');
    
    if (node.properties['type'] != null) {
      // Strip any AI-hallucinated prefix so we never get double "BottomNavigationBarType."
      final rawType = node.properties['type'].toString()
          .replaceAll('BottomNavigationBarType.', '');
      if (rawType == 'fixed' || rawType == 'shifting') {
        props.add('type: BottomNavigationBarType.$rawType');
      }
    }
    
    if (node.properties['backgroundColor'] != null) {
      props.add('backgroundColor: Color(${node.properties['backgroundColor']})');
    }
    
    if (node.properties['selectedItemColor'] != null) {
      props.add('selectedItemColor: Color(${node.properties['selectedItemColor']})');
    }
    
    if (node.properties['unselectedItemColor'] != null) {
      props.add('unselectedItemColor: Color(${node.properties['unselectedItemColor']})');
    }
    
    // Handle items from properties (primary method)
    List<String> itemsList = [];
    if (node.properties['items'] != null && node.properties['items'] is List) {
      final items = node.properties['items'] as List;
      for (final item in items) {
        if (item is Map) {
          final itemMap = Map<String, dynamic>.from(item);
          String iconCode = 'Icon(Icons.home)'; // default
          String label = 'Item'; // default
          
          // Handle icon
          final iconData = itemMap['icon'];
          if (iconData != null) {
            if (iconData is WidgetNode) {
              iconCode = WidgetGeneratorRegistry.generateCode(iconData, indent: 0);
            } else if (iconData is Map) {
              final iconNode = WidgetNode.fromJson(Map<String, dynamic>.from(iconData));
              iconCode = WidgetGeneratorRegistry.generateCode(iconNode, indent: 0);
            } else if (iconData is String) {
              iconCode = 'Icon($iconData)';
            }
          }
          
          // Handle label
          if (itemMap['label'] != null) {
            label = itemMap['label'].toString();
          }
          
          itemsList.add('BottomNavigationBarItem(icon: $iconCode, label: ${dartString(label)})');
        }
      }
    }
    
    // Fallback: Handle items from children (secondary method)
    if (itemsList.isEmpty && node.children.isNotEmpty) {
      itemsList = node.children.map((child) {
        return 'BottomNavigationBarItem('
          'icon: Icon(Icons.${child.properties['icon'] ?? 'home'}), '
          'label: ${dartString(child.properties['label'] ?? 'Item')}'
          ')';
      }).toList();
    }
    
    // Ensure at least 2 items (Flutter requirement)
    if (itemsList.isEmpty) {
      itemsList = [
        'BottomNavigationBarItem(icon: Icon(Icons.home), label: \'Home\')',
        'BottomNavigationBarItem(icon: Icon(Icons.search), label: \'Search\')',
      ];
    } else if (itemsList.length == 1) {
      itemsList.add('BottomNavigationBarItem(icon: Icon(Icons.search), label: \'Search\')');
    }
    
    final itemsString = itemsList.join(',\n$childIndentStr');
    props.add('items: [\n$childIndentStr$itemsString\n$indentStr]');
    
    return '${indentStr}BottomNavigationBar(\n$childIndentStr${props.join(',\n$childIndentStr')}\n$indentStr)';
  }
} 