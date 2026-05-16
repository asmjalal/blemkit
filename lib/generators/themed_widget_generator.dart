import '../models/widget_node.dart';
import 'base_widget_generator.dart';
import 'widget_generator_registry.dart';

class ThemedWidgetGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final String? themedId = node.properties['themedWidgetId'];
    if (themedId == null) return '// Error: Invalid Themed Widget ID';

    final themedWidgets = (BaseWidgetGenerator.themeProps['themedWidgets'] as List<dynamic>?) ?? [];
    final themedDef = themedWidgets.firstWhere(
      (w) => w['id'] == themedId,
      orElse: () => null,
    );

    if (themedDef == null) return '// Error: Themed Widget $themedId not found';

    final baseType = themedDef['type'] ?? 'Container';
    final properties = Map<String, dynamic>.from(themedDef['properties'] ?? {});
    
    // Create a virtual node to generate the base widget code
    final virtualNode = WidgetNode(
      type: baseType,
      properties: properties,
      children: node.children,
    );

    // Use the registry to generate code for the underlying base widget
    return WidgetGeneratorRegistry.generateCode(virtualNode, indent: indent);
  }
}
