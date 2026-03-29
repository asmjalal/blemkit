import '../base_widget_generator.dart';
import '../../models/widget_node.dart';
import '../widget_generator_registry.dart';

class BottomNavigationBarGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    props.add('currentIndex: ${node.properties['currentIndex'] ?? 0}');
    props.add('onTap: (index) {}');
    
    if (node.properties['type'] != null) {
      props.add('type: BottomNavigationBarType.${node.properties['type']}');
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
        if (item is Map<String, dynamic>) {
          String iconCode = 'Icon(Icons.home)'; // default
          String label = 'Item'; // default
          
          // Handle icon
          if (item['icon'] != null) {
            if (item['icon'] is Map<String, dynamic>) {
              final iconNode = WidgetNode.fromJson(item['icon']);
              iconCode = WidgetGeneratorRegistry.generateCode(iconNode, indent: 0);
            } else if (item['icon'] is String) {
              iconCode = 'Icon(${item['icon']})';
            }
          }
          
          // Handle label
          if (item['label'] != null) {
            label = item['label'].toString();
          }
          
          itemsList.add('BottomNavigationBarItem(icon: $iconCode, label: \'$label\')');
        }
      }
    }
    
    // Fallback: Handle items from children (secondary method)
    if (itemsList.isEmpty && node.children.isNotEmpty) {
      itemsList = node.children.map((child) {
        return 'BottomNavigationBarItem('
          'icon: Icon(Icons.${child.properties['icon'] ?? 'home'}), '
          'label: \'${child.properties['label'] ?? 'Item'}\''
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