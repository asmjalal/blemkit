import 'base_widget_generator.dart';
import '../models/widget_node.dart';
import 'widget_generator_registry.dart';

class AspectRatioGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final aspectRatio = node.properties['aspectRatio']?.toString() ?? '1.0';
    
    final childCode = node.children.isNotEmpty
        ? '\n$childIndentStr${'child: ${WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1).trim()}'}'
        : '';
        
    return '''${indentStr}AspectRatio(
${childIndentStr}aspectRatio: $aspectRatio,$childCode
$indentStr)''';
  }
}
