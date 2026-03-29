import '../base_widget_generator.dart';
import '../../models/widget_node.dart';
import '../widget_generator_registry.dart';

class CardGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    if (node.properties['color'] != null) {
      props.add('color: Color(${node.properties['color']})');
    }
    
    if (node.properties['elevation'] != null) {
      props.add('elevation: ${node.properties['elevation']}');
    }
    
    if (node.properties['margin'] != null) {
      final margin = node.properties['margin'];
      if (margin is Map) {
        final left = margin['left'] ?? 0;
        final right = margin['right'] ?? 0;
        final top = margin['top'] ?? 0;
        final bottom = margin['bottom'] ?? 0;
        props.add('margin: EdgeInsets.only(left: $left, top: $top, right: $right, bottom: $bottom)');
      } else {
        props.add('margin: EdgeInsets.all($margin)');
      }
    }
    
    if (node.properties['shape'] != null) {
      final shape = node.properties['shape'];
      if (shape is Map && shape['borderRadius'] != null) {
        props.add('shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(${shape['borderRadius']}))');
      } else if (shape is String) {
        props.add('shape: $shape');
      }
    }
    
    String child = '';
    if (node.children.isNotEmpty) {
      child = '\n$childIndentStr child: ${WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1)},';
    }
    
    return '${indentStr}Card(${props.isNotEmpty ? '\n$childIndentStr${props.join(',\n$childIndentStr')}${child.isNotEmpty ? ',' : ''}' : ''}$child\n$indentStr)';
  }
} 