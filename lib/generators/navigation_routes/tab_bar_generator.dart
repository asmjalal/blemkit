import '../base_widget_generator.dart';
import '../../models/widget_node.dart';

class TabBarGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    props.add('controller: TabController(length: ${node.children.length}, vsync: this)');
    
    if (node.properties['labelColor'] != null) {
      props.add('labelColor: Color(${node.properties['labelColor']})');
    }
    
    if (node.properties['unselectedLabelColor'] != null) {
      props.add('unselectedLabelColor: Color(${node.properties['unselectedLabelColor']})');
    }
    
    if (node.properties['indicatorColor'] != null) {
      props.add('indicatorColor: Color(${node.properties['indicatorColor']})');
    }
    
    final tabs = node.children.map((child) {
      return 'Tab(' +
        'icon: Icon(Icons.${child.properties['icon'] ?? 'home'}), ' +
        'text: \'${child.properties['text'] ?? 'Tab'}\'' +
        ')';
    }).join(',\n$childIndentStr');
    
    props.add('tabs: [\n$childIndentStr $tabs\n$indentStr]');
    
    return '${indentStr}TabBar(${props.join(',\n$childIndentStr ')}\n$indentStr)';
  }
}

class TabBarViewGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    props.add('controller: TabController(length: ${node.children.length}, vsync: this)');
    
    final children = generateChildren(node.children, indent: indent);
    
    return '${indentStr}TabBarView(${props.join(', ')}$children\n$indentStr)';
  }
}