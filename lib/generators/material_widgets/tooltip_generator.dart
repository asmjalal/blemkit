import '../base_widget_generator.dart';
import '../../models/widget_node.dart';
import '../widget_generator_registry.dart';

class TooltipGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    if (node.properties['message'] != null) {
      props.add('message: \'${node.properties['message']}\'');
    }
    
    if (node.properties['height'] != null) {
      props.add('height: ${node.properties['height']}');
    }
    
    if (node.properties['padding'] != null) {
      props.add('padding: EdgeInsets.all(${node.properties['padding']})');
    }
    
    if (node.properties['verticalOffset'] != null) {
      props.add('verticalOffset: ${node.properties['verticalOffset']}');
    }
    
    if (node.properties['preferBelow'] != null) {
      props.add('preferBelow: ${node.properties['preferBelow']}');
    }
    
    final child = node.children.isNotEmpty 
        ? WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1)
        : 'Container()';
    
    props.add('child: $child');
    
    return '${indentStr}Tooltip(${props.join(',\n$childIndentStr ')}\n$indentStr)';
  }
} 