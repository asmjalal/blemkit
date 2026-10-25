import 'base_widget_generator.dart';
import '../models/widget_node.dart';

class RichTextGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final textSpans = node.children.map((child) {
      final style = <String>[];
      if (child.properties['color'] != null) {
        style.add('color: Color(${child.properties['color']})');
      }
      if (child.properties['fontSize'] != null) {
        style.add('fontSize: ${child.properties['fontSize']}');
      }
      if (child.properties['fontWeight'] != null) {
        style.add('fontWeight: FontWeight.${child.properties['fontWeight']}');
      }
      
      final styleStr = style.isNotEmpty ? ', style: TextStyle(${style.join(', ')})' : '';
      return 'TextSpan(text: ${dartString(child.properties['text'] ?? '')}$styleStr)';
    }).join(',\n$childIndentStr');
    
    return '${indentStr}RichText(\n$childIndentStr text: TextSpan(\n$childIndentStr $textSpans\n$childIndentStr )\n$indentStr)';
  }
} 