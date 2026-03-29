import 'base_widget_generator.dart';
import 'widget_generator_registry.dart';
import '../models/widget_node.dart';

class PaddingGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    if (node.properties['padding'] != null) {
      props.add('padding: EdgeInsets.all(${node.properties['padding']})');
    } else if (node.properties['horizontal'] != null || node.properties['vertical'] != null) {
      props.add('padding: EdgeInsets.symmetric(' +
        'horizontal: ${node.properties['horizontal'] ?? 0.0}, ' +
        'vertical: ${node.properties['vertical'] ?? 0.0})');
    }
    
    String child = '';
    if (node.children.isNotEmpty) {
      child = '\n$childIndentStr child: ${generateCode(node.children.first, indent: indent + 1)},';
    }
    
    return '${indentStr}Padding(${props.join(', ')}$child\n$indentStr)';
  }
} 