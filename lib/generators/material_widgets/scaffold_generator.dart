import '../base_widget_generator.dart';
import '../../models/widget_node.dart';
import '../widget_generator_registry.dart';

class ScaffoldGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];

    // Use generateProperties for all properties
    final generatedProps = generateProperties(node.properties, indent: indent + 1);
    if (generatedProps.isNotEmpty) {
      props.add(generatedProps);
    }
    
    // Special handling for body if it's a direct child (less common for Scaffold, but possible)
    // The body property should ideally be handled by generateProperties if it's a map in node.properties
    // This ensures that if the body is explicitly set as a child, it's still rendered.
    // However, if body is a property map, generateProperties will handle it.
    // The example output shows `body: Scaffold(body: ...)` which suggests multiple nested Scaffolds.
    // Let's assume the primary body comes from a property for now, and handle children as fallback/additional content.

    String childrenCode = generateChildren(node.children, indent: indent);
    if (childrenCode.isNotEmpty && !node.properties.containsKey('body')) {
      // If there's no 'body' property but there are children, treat the first child as the body
      // and remaining children as additional content (potentially wrapped in a Column implicitly).
      // This might need more sophisticated handling based on the actual UI builder logic.
      // For simplicity, if there's no body property, and there are children, put them in a body.
      if (node.children.isNotEmpty) {
        props.add('body: ${WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1)}');
      }
    }

    return '${indentStr}Scaffold(${props.join(',\n$childIndentStr ')}\n$indentStr)';
  }
} 