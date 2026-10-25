import 'base_widget_generator.dart';
import '../models/widget_node.dart';
import 'widget_generator_registry.dart';

class BadgeGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    final label = node.properties['label']?.toString();
    if (label != null) {
      props.add("label: Text(${dartString(label)})");
    }
    
    if (node.properties['isLabelVisible'] == false) {
      props.add('isLabelVisible: false');
    }
    
    if (node.properties['backgroundColor'] != null) {
      props.add('backgroundColor: ${formatColor(node.properties['backgroundColor'])}');
    }
    
    if (node.properties['textColor'] != null) {
      props.add('textColor: ${formatColor(node.properties['textColor'])}');
    }
    
    final childCode = node.children.isNotEmpty
        ? '\n$childIndentStr${'child: ${WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1).trim()}'}'
        : '';
        
    final propsString = props.isNotEmpty ? '\n$childIndentStr${props.join(',\n$childIndentStr')},' : '';

    return '''${indentStr}Badge($propsString$childCode
$indentStr)''';
  }
}
