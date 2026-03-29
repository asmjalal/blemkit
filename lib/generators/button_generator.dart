import 'base_widget_generator.dart';
import 'widget_generator_registry.dart';
import '../models/widget_node.dart';

class ButtonGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    
    String child;
    if (node.children.isNotEmpty) {
      child = generateCode(node.children.first, indent: indent + 1);
    } else {
      child = "Text('${node.properties['text'] ?? 'Button'}')";
    }
    
    return '${indentStr}ElevatedButton(onPressed: () {}, child: $child)';
  }
} 