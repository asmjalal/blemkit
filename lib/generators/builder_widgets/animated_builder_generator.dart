import '../base_widget_generator.dart';
import '../../models/widget_node.dart';
import '../widget_generator_registry.dart';

class AnimatedBuilderGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    props.add('animation: AnimationController(vsync: this)');
    
    final builder = node.children.isNotEmpty 
        ? WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1)
        : 'Container()';
    
    props.add('builder: (context, child) => $builder');
    
    if (node.properties['child'] != null) {
      props.add('child: ${node.properties['child']}');
    }
    
    return '${indentStr}AnimatedBuilder(${props.join(',\n$childIndentStr ')}\n$indentStr)';
  }
} 