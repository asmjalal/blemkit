import 'base_widget_generator.dart';
import '../models/widget_node.dart';
import 'widget_generator_registry.dart';

class IconButtonGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);

    final props = <String>[];

    // Handle icon property (can be nested Icon widget)
    if (node.properties['icon'] != null) {
      final iconData = node.properties['icon'];
      if (iconData is Map<String, dynamic>) {
        final iconNode = WidgetNode.fromJson(iconData);
        props.add('icon: ${WidgetGeneratorRegistry.generateCode(iconNode, indent: 0)}');
      } else if (iconData is String) {
        props.add('icon: Icon($iconData)');
      }
    } else {
      props.add('icon: const Icon(Icons.help)'); // Default fallback
    }

    // Handle onPressed
    if (node.properties['onPressed'] != null) {
      props.add('onPressed: () {}');
    } else {
      props.add('onPressed: () {}'); // Always provide onPressed
    }

    // Handle other properties
    if (node.properties['color'] != null) {
      props.add('color: Color(${node.properties['color']})');
    }
    
    if (node.properties['iconSize'] != null) {
      props.add('iconSize: ${node.properties['iconSize']}');
    }
    
    if (node.properties['tooltip'] != null) {
      props.add('tooltip: \'${node.properties['tooltip']}\'');
    }

    return props.isEmpty 
        ? '${indentStr}IconButton(onPressed: () {}, icon: const Icon(Icons.help))'
        : '${indentStr}IconButton(\n$childIndentStr${props.join(',\n$childIndentStr')}\n$indentStr)';
  }
} 