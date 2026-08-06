import 'base_widget_generator.dart';
import 'widget_generator_registry.dart';
import '../models/widget_node.dart';

class FlexibleGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    if (node.properties['flex'] != null) {
      props.add('flex: ${node.properties['flex']}');
    }
    if (node.properties['fit'] != null) {
      final fit = node.properties['fit'].toString().split('.').last;
      props.add('fit: FlexFit.$fit');
    }
    
    String child = '';
    if (node.children.isNotEmpty) {
      child = '\n$childIndentStr child: ${WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1)},';
    }
    
    return '${indentStr}Flexible(${props.isNotEmpty ? '${props.join(', ')}${child.isNotEmpty ? ',' : ''}' : ''}$child\n$indentStr)';
  }
}
