import 'base_widget_generator.dart';
import 'widget_generator_registry.dart';
import '../models/widget_node.dart';

class ButtonGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    
    String child;
    if (node.children.isNotEmpty) {
      child = WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1).trim();
    } else {
      child = "Text('${node.properties['text'] ?? 'Button'}')";
    }
    
    final onPressedCode = generateNavigationCode(node.properties['navigateTo']);
    return '${indentStr}ElevatedButton(onPressed: $onPressedCode, child: $child)';
  }
} 