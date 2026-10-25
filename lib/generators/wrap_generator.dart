import 'base_widget_generator.dart';
import '../models/widget_node.dart';
import 'widget_generator_registry.dart';

class WrapGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final direction = node.properties['direction'] == 'vertical' ? 'Axis.vertical' : 'Axis.horizontal';
    final alignment = node.properties['alignment'] != null ? 'WrapAlignment.${node.properties['alignment']}' : 'WrapAlignment.start';
    final spacing = node.properties['spacing']?.toString() ?? '0.0';
    final runAlignment = node.properties['runAlignment'] != null ? 'WrapAlignment.${node.properties['runAlignment']}' : 'WrapAlignment.start';
    final runSpacing = node.properties['runSpacing']?.toString() ?? '0.0';
    final crossAxisAlignment = node.properties['crossAxisAlignment'] != null ? 'WrapCrossAlignment.${node.properties['crossAxisAlignment']}' : 'WrapCrossAlignment.start';

    final childrenCode = node.children.isEmpty
        ? '[]'
        : '[\n${node.children.map((c) => '${getChildIndentStr(indent + 1)}${WidgetGeneratorRegistry.generateCode(c, indent: indent + 2)},').join('\n')}\n$childIndentStr]';

    return '''${indentStr}Wrap(
${childIndentStr}direction: $direction,
${childIndentStr}alignment: $alignment,
${childIndentStr}spacing: $spacing,
${childIndentStr}runAlignment: $runAlignment,
${childIndentStr}runSpacing: $runSpacing,
${childIndentStr}crossAxisAlignment: $crossAxisAlignment,
${childIndentStr}children: $childrenCode,
$indentStr)''';
  }
}
