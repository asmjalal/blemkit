import 'base_widget_generator.dart';
import 'widget_generator_registry.dart';
import '../models/widget_node.dart';

class PaddingGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    if (node.properties['padding'] != null) {
      props.add('padding: const ${parseEdgeInsets(node.properties['padding'])}');
    } else {
      final pTop = (node.properties['paddingTop'] is num) ? node.properties['paddingTop'].toDouble() : 0.0;
      final pRight = (node.properties['paddingRight'] is num) ? node.properties['paddingRight'].toDouble() : 0.0;
      final pBottom = (node.properties['paddingBottom'] is num) ? node.properties['paddingBottom'].toDouble() : 0.0;
      final pLeft = (node.properties['paddingLeft'] is num) ? node.properties['paddingLeft'].toDouble() : 0.0;
      
      if (pTop != 0 || pBottom != 0 || pLeft != 0 || pRight != 0) {
        props.add('padding: const EdgeInsets.only(left: $pLeft, top: $pTop, right: $pRight, bottom: $pBottom)');
      }
    }
    
    if (props.isEmpty) props.add('padding: EdgeInsets.zero');
    final child = node.children.isNotEmpty
        ? WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1).trimLeft()
        : 'const SizedBox.shrink()';

    return '${indentStr}Padding(\n$childIndentStr ${props.join(', ')},\n$childIndentStr child: $child,\n$indentStr)';
  }
} 