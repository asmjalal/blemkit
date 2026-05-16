import 'base_widget_generator.dart';
import '../models/widget_node.dart';
import 'widget_generator_registry.dart';
import '../utils/property_converters.dart';

class AvatarGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    final radius = node.properties['radius']?.toString();
    if (radius != null) props.add('radius: $radius');
    
    if (node.properties['backgroundColor'] != null) {
      props.add('backgroundColor: ${formatColor(node.properties['backgroundColor'])}');
    }
    
    if (node.properties['foregroundColor'] != null) {
      props.add('foregroundColor: ${formatColor(node.properties['foregroundColor'])}');
    }
    
    final src = node.properties['src']?.toString();
    if (src != null && src.isNotEmpty) {
      props.add("backgroundImage: NetworkImage('$src')");
    }
    
    final childCode = node.children.isNotEmpty
        ? '\n$childIndentStr${'child: ${WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1).trim()}'}'
        : '';
        
    final propsString = props.isNotEmpty ? '\n$childIndentStr${props.join(',\n$childIndentStr')},' : '';

    return '''${indentStr}CircleAvatar($propsString$childCode
$indentStr)''';
  }
}
