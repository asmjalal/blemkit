import 'base_widget_generator.dart';
import '../models/widget_node.dart';
import 'widget_generator_registry.dart';

class ExpandableGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    final itemIndentStr = getChildIndentStr(indent + 1);
    
    final hasIcon = node.properties['hasIcon']?.toString() ?? 'true';
    final iconPlacement = node.properties['iconPlacement'] == 'left' ? 'ExpandablePanelIconPlacement.left' : 'ExpandablePanelIconPlacement.right';

    final headerCode = node.children.isNotEmpty 
        ? WidgetGeneratorRegistry.generateCode(node.children[0], indent: indent + 1).trim()
        : "Text('Header')";
        
    final expandedCode = node.children.length > 1
        ? WidgetGeneratorRegistry.generateCode(node.children[1], indent: indent + 1).trim()
        : "Text('Expanded Content')";

    return '''${indentStr}ExpandablePanel(
${childIndentStr}header: $headerCode,
${childIndentStr}collapsed: const SizedBox.shrink(),
${childIndentStr}expanded: $expandedCode,
${childIndentStr}theme: ExpandableThemeData(
${itemIndentStr}hasIcon: $hasIcon,
${itemIndentStr}iconPlacement: $iconPlacement,
${childIndentStr}),
$indentStr)''';
  }
}
