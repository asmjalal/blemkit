import '../../models/widget_node.dart';
import 'base_widget_generator.dart';
import 'widget_generator_registry.dart';

class ClipRRectGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = '  ' * indent;
    final childIndent = '  ' * (indent + 1);

    final borderRadiusValue = (node.properties['borderRadius'] as num?)?.toDouble() ?? 0.0;

    final childCode = node.children.isNotEmpty
        ? WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1)
        : '${childIndent}const SizedBox.shrink(),\n';

    return '${indentStr}ClipRRect(\n'
        '${childIndent}borderRadius: BorderRadius.circular($borderRadiusValue),\n'
        '${childIndent}child: $childCode'
        '$indentStr),\n';
  }
}
