import 'base_widget_generator.dart';
import '../models/widget_node.dart';

class InkWellGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    if (node.properties['onTap'] != null) {
      props.add('onTap: () {}');
    }
    if (node.properties['splashColor'] != null) {
      props.add('splashColor: Color(${node.properties['splashColor']})');
    }
    if (node.properties['highlightColor'] != null) {
      props.add('highlightColor: Color(${node.properties['highlightColor']})');
    }
    
    String child = '';
    if (node.children.isNotEmpty) {
      child = '\n$childIndentStr child: ${generateCode(node.children.first, indent: indent + 1)},';
    }
    
    return '${indentStr}InkWell(${props.join(', ')}$child\n$indentStr)';
  }
} 