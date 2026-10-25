import '../base_widget_generator.dart';
import '../../models/widget_node.dart';

class TabBarGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    if (node.properties['labelColor'] != null) {
      props.add('labelColor: ${formatColor(node.properties['labelColor'])}');
    }
    
    if (node.properties['unselectedLabelColor'] != null) {
      props.add('unselectedLabelColor: ${formatColor(node.properties['unselectedLabelColor'])}');
    }
    
    if (node.properties['indicatorColor'] != null) {
      props.add('indicatorColor: ${formatColor(node.properties['indicatorColor'])}');
    }
    
    final tabs = node.children.map((child) {
      return 'Tab(' +
        (child.properties['icon'] != null ? 'icon: Icon(Icons.${'${child.properties['icon']}'.replaceFirst('Icons.', '')}), ' : '') +
        'text: ${dartString(child.properties['text'] ?? 'Tab')}' +
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
    
    final children = generateChildren(node.children, indent: indent);

    return '${indentStr}TabBarView(${props.isEmpty ? '' : '${props.join(', ')},'}$children\n$indentStr)';
  }
}