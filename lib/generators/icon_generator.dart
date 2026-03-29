import 'base_widget_generator.dart';
import '../models/widget_node.dart';
import 'widget_generator_registry.dart';

class IconGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];

    // Handle icon property - this should be the first positional argument
    String iconName = 'Icons.help'; // Default
    if (node.properties['icon'] != null) {
      final iconValue = node.properties['icon'].toString();
      if (iconValue.startsWith('Icons.')) {
        iconName = iconValue;
      } else {
        iconName = 'Icons.$iconValue';
      }
    }

    // Handle size
    if (node.properties['size'] != null) {
      props.add('size: ${node.properties['size']}');
    }

    // Handle color
    if (node.properties['color'] != null) {
      props.add('color: ${formatColor(node.properties['color'])}');
    }

    // Icon constructor: Icon(iconData, {size, color, ...})
    if (props.isEmpty) {
      return '${indentStr}Icon($iconName)';
    } else {
      return '${indentStr}Icon($iconName,\n$childIndentStr${props.join(',\n$childIndentStr')}\n$indentStr)';
    }
  }
} 