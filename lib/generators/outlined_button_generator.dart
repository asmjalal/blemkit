import 'base_widget_generator.dart';
import 'widget_generator_registry.dart';
import '../models/widget_node.dart';

class OutlinedButtonGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    if (node.properties['onPressed'] != null) {
      props.add('onPressed: () {}');
    }
    if (node.properties['style'] != null) {
      props.add('style: OutlinedButton.styleFrom(' +
        'foregroundColor: Color(${node.properties['foregroundColor'] ?? '0xFF2196F3'}), ' +
        'side: BorderSide(color: Color(${node.properties['borderColor'] ?? '0xFF2196F3'})), ' +
        'padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)' +
        ')');
    }
    
    String child = '';
    if (node.children.isNotEmpty) {
      child = '\n$childIndentStr child: ${WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1)},';
    } else if (node.properties['text'] != null) {
      // Escape dollar signs in text
      final textContent = node.properties['text'].toString().replaceAll('\$', '\\\$');
      child = '\n$childIndentStr child: Text(\'$textContent\'),';
    }
    
    return '${indentStr}OutlinedButton(${props.isNotEmpty ? '${props.join(', ')}${child.isNotEmpty ? ',' : ''}' : ''}$child\n$indentStr)';
  }
} 