import 'base_widget_generator.dart';
import '../models/widget_node.dart';
import 'widget_generator_registry.dart';

class ElevatedButtonGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    if (node.properties['onPressed'] != null) {
      props.add('onPressed: () {}');
    }
    if (node.properties['style'] != null || node.properties['backgroundColor'] != null || node.properties['foregroundColor'] != null) {
      final bgColor = formatColor(node.properties['backgroundColor'] ?? '0xFF2196F3');
      final fgColor = formatColor(node.properties['foregroundColor'] ?? '0xFFFFFFFF');
      props.add('style: ElevatedButton.styleFrom(' +
        'backgroundColor: $bgColor, ' +
        'foregroundColor: $fgColor, ' +
        'padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)' +
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
    
    return '${indentStr}ElevatedButton(${props.isNotEmpty ? '${props.join(', ')}${child.isNotEmpty ? ',' : ''}' : ''}$child\n$indentStr)';
  }
} 