import '../base_widget_generator.dart';
import '../widget_generator_registry.dart';
import '../../models/widget_node.dart';

class MediaQueryGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    if (node.properties['data'] != null) {
      props.add('data: MediaQueryData(${node.properties['data']})');
    }
    
    final child = node.children.isNotEmpty 
        ? WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1)
        : 'Container()';
    
    props.add('child: $child');
    
    return '${indentStr}MediaQuery(${props.join(',\n$childIndentStr ')}\n$indentStr)';
  }
} 