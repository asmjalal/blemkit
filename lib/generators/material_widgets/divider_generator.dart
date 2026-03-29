import '../base_widget_generator.dart';
import '../../models/widget_node.dart';

class DividerGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    if (node.properties['height'] != null) {
      props.add('height: ${node.properties['height']}');
    }
    
    if (node.properties['thickness'] != null) {
      props.add('thickness: ${node.properties['thickness']}');
    }
    
    if (node.properties['color'] != null) {
      props.add('color: Color(${node.properties['color']})');
    }
    
    if (node.properties['indent'] != null) {
      props.add('indent: ${node.properties['indent']}');
    }
    
    if (node.properties['endIndent'] != null) {
      props.add('endIndent: ${node.properties['endIndent']}');
    }
    
    return '${indentStr}Divider(${props.join(',\n$childIndentStr ')}\n$indentStr)';
  }
} 