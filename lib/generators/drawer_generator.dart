import 'base_widget_generator.dart';
import '../models/widget_node.dart';
import 'widget_generator_registry.dart';

class DrawerGenerator extends BaseWidgetGenerator {
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

    // If no child is provided in properties, and no direct children, add a default ListView.
    // This fallback is for drawers that might be created without an explicit child.
    if (!node.properties.containsKey('child') && node.children.isEmpty) {
      props.add('child: ListView()');
    }
    
    return '${indentStr}Drawer(${props.join(',\n$childIndentStr ')}\n$indentStr)';
  }
} 