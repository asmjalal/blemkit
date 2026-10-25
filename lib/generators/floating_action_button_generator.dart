import 'base_widget_generator.dart';
import '../models/widget_node.dart';

class FloatingActionButtonGenerator extends BaseWidgetGenerator {
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

    // Ensure onPressed is handled
    final actions = node.properties['actions'] as List<dynamic>?;
    final fallbackNavigateTo = node.properties['navigateTo'];
    if (actions != null || fallbackNavigateTo != null || node.properties['onPressed'] != null) {
      props.add('onPressed: ${generateActionFlowCode(actions, fallbackNavigateTo)}');
    } else {
      props.add('onPressed: () {}');
    }

    // If no child is provided in properties, and no direct children, add a default Icon.
    // This fallback is crucial for FABs that might be created without an explicit child.
    if (!node.properties.containsKey('child') && node.children.isEmpty) {
      props.add('child: const Icon(Icons.add)');
    }

    return '${indentStr}FloatingActionButton(${props.join(',\n$childIndentStr ')}\n$indentStr)';
  }
} 