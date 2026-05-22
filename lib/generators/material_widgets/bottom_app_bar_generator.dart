import '../base_widget_generator.dart';
import '../widget_generator_registry.dart';
import '../../models/widget_node.dart';

class BottomAppBarGenerator extends BaseWidgetGenerator {
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
    
    if (node.properties['shape'] != null) {
      props.add('shape: ${node.properties['shape']}');
    }
    
    if (node.properties['notchMargin'] != null) {
      props.add('notchMargin: ${node.properties['notchMargin']}');
    }
    
    final child = node.children.isNotEmpty 
        ? WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1)
        : 'Container()';
    
    props.add('child: $child');
    
    return '${indentStr}BottomAppBar(${props.join(',\n$childIndentStr ')}\n$indentStr)';
  }
} 