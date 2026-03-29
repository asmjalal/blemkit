import 'base_widget_generator.dart';
import 'widget_generator_registry.dart';
import '../models/widget_node.dart';

class PositionedGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    if (node.properties['left'] != null) props.add('left: ${node.properties['left']}');
    if (node.properties['top'] != null) props.add('top: ${node.properties['top']}');
    if (node.properties['right'] != null) props.add('right: ${node.properties['right']}');
    if (node.properties['bottom'] != null) props.add('bottom: ${node.properties['bottom']}');
    if (node.properties['width'] != null) props.add('width: ${node.properties['width']}');
    if (node.properties['height'] != null) props.add('height: ${node.properties['height']}');
    
    String child = '';
    if (node.children.isNotEmpty) {
      child = '\n$childIndentStr child: ${WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1)},';
    }
    
    return '${indentStr}Positioned(${props.isNotEmpty ? '${props.join(', ')}${child.isNotEmpty ? ',' : ''}' : ''}$child\n$indentStr)';
  }
} 