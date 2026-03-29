import '../base_widget_generator.dart';
import '../../models/widget_node.dart';
import '../widget_generator_registry.dart';

class OrientationBuilderGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    final builder = node.children.isNotEmpty 
        ? WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1)
        : 'Container()';
    
    props.add('builder: (context, orientation) => $builder');
    
    return '${indentStr}OrientationBuilder(${props.join(',\n$childIndentStr ')}\n$indentStr)';
  }
} 