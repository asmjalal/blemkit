import 'base_widget_generator.dart';
import '../models/widget_node.dart';
import 'widget_generator_registry.dart';

class SafeAreaGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    if (node.properties['left'] == false) props.add('left: false');
    if (node.properties['top'] == false) props.add('top: false');
    if (node.properties['right'] == false) props.add('right: false');
    if (node.properties['bottom'] == false) props.add('bottom: false');
    
    final childCode = node.children.isNotEmpty
        ? '\n$childIndentStr${'child: ${WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1).trim()}'}'
        : '';
        
    final propsString = props.isNotEmpty ? '\n$childIndentStr${props.join(',\n$childIndentStr')},' : '';

    return '''${indentStr}SafeArea($propsString$childCode
$indentStr)''';
  }
}
