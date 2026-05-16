import 'base_widget_generator.dart';
import '../models/widget_node.dart';
import 'widget_generator_registry.dart';

class ConstrainedBoxGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    final itemIndentStr = getChildIndentStr(indent + 1);
    
    final minWidth = node.properties['minWidth']?.toString() ?? '0.0';
    final maxWidth = node.properties['maxWidth']?.toString() ?? 'double.infinity';
    final minHeight = node.properties['minHeight']?.toString() ?? '0.0';
    final maxHeight = node.properties['maxHeight']?.toString() ?? 'double.infinity';
    
    final childCode = node.children.isNotEmpty
        ? '\n$childIndentStr${'child: ${WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1).trim()}'}'
        : '';
        
    return '''${indentStr}ConstrainedBox(
${childIndentStr}constraints: BoxConstraints(
${itemIndentStr}minWidth: $minWidth,
${itemIndentStr}maxWidth: $maxWidth,
${itemIndentStr}minHeight: $minHeight,
${itemIndentStr}maxHeight: $maxHeight,
${childIndentStr}),$childCode
$indentStr)''';
  }
}
