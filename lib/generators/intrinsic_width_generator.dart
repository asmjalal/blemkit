import 'base_widget_generator.dart';
import '../models/widget_node.dart';
import 'widget_generator_registry.dart';

class IntrinsicWidthGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final childCode = node.children.isNotEmpty
        ? '\n$childIndentStr${'child: ${WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1).trim()}'}'
        : '';
        
    return '''${indentStr}IntrinsicWidth($childCode
$indentStr)''';
  }
}
