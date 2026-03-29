import '../base_widget_generator.dart';
import '../../models/widget_node.dart';
import '../widget_generator_registry.dart';

class SingleChildScrollViewGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    if (node.properties['scrollDirection'] != null) {
      props.add('scrollDirection: Axis.${node.properties['scrollDirection']}');
    }
    
    if (node.properties['padding'] != null) {
      final padding = node.properties['padding'];
      if (padding is Map) {
        // Handle EdgeInsets.only or EdgeInsets.symmetric
        final left = padding['left'] ?? 0;
        final right = padding['right'] ?? 0;
        final top = padding['top'] ?? 0;
        final bottom = padding['bottom'] ?? 0;
        props.add('padding: EdgeInsets.only(left: $left, top: $top, right: $right, bottom: $bottom)');
      } else {
        // Handle EdgeInsets.all
        props.add('padding: EdgeInsets.all($padding)');
      }
    }
    
    String child = '';
    if (node.children.isNotEmpty) {
      child = '\n$childIndentStr child: ${WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1)},';
    }
    
    return '${indentStr}SingleChildScrollView(${props.join(', ')}$child\n$indentStr)';
  }
} 