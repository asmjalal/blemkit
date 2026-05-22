import 'base_widget_generator.dart';
import 'widget_generator_registry.dart';
import '../models/widget_node.dart';

class GestureDetectorGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    if (node.properties['onTap'] != null) {
      props.add('onTap: () {}');
    }
    if (node.properties['onDoubleTap'] != null) {
      props.add('onDoubleTap: () {}');
    }
    if (node.properties['onLongPress'] != null) {
      props.add('onLongPress: () {}');
    }
    
    String child = '';
    if (node.children.isNotEmpty) {
      child = '\n$childIndentStr child: ${WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1)},';
    }
    
    return '${indentStr}GestureDetector(${props.join(', ')}$child\n$indentStr)';
  }
} 