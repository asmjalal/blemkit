import 'base_widget_generator.dart';
import 'widget_generator_registry.dart';
import '../models/widget_node.dart';

class OutlinedButtonGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    final actions = node.properties['actions'] as List<dynamic>?;
    final fallbackNavigateTo = node.properties['navigateTo'];
    if (actions != null || fallbackNavigateTo != null || node.properties['onPressed'] != null) {
      props.add('onPressed: ${generateActionFlowCode(actions, fallbackNavigateTo)}');
    } else {
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
      final textContent = node.properties['text'].toString();
      child = '\n$childIndentStr child: Text(${dartString(textContent)}),';
    }
    
    return '${indentStr}OutlinedButton(${props.isNotEmpty ? '${props.join(', ')}${child.isNotEmpty ? ',' : ''}' : ''}$child\n$indentStr)';
  }
} 