import '../base_widget_generator.dart';
import '../widget_generator_registry.dart';
import '../../models/widget_node.dart';

class FormGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>['key: GlobalKey<FormState>()'];
    
    
    
    if (node.properties['autovalidateMode'] != null) {
      props.add('autovalidateMode: AutovalidateMode.${node.properties['autovalidateMode']}');
    }
    
    final String child;
    if (node.children.length == 1) {
      child = WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1).trimLeft();
    } else {
      child = 'Column(${generateChildren(node.children, indent: indent + 1)}\n$childIndentStr)';
    }

    return '${indentStr}Form(${props.join(', ')},\n$childIndentStr child: $child,\n$indentStr)';
  }
} 