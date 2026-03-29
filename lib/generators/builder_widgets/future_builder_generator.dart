import '../base_widget_generator.dart';
import '../../models/widget_node.dart';
import '../widget_generator_registry.dart';

class FutureBuilderGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    props.add('future: Future.value(null)');
    
    final builder = node.children.isNotEmpty 
        ? WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1)
        : 'Container()';
    
    props.add('builder: (context, snapshot) => $builder');
    
    return '${indentStr}FutureBuilder(${props.join(',\n$childIndentStr ')}\n$indentStr)';
  }
} 