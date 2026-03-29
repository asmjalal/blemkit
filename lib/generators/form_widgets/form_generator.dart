import '../base_widget_generator.dart';
import '../../models/widget_node.dart';

class FormGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    props.add('key: GlobalKey<FormState>()');
    
    if (node.properties['onChanged'] != null) {
      props.add('onChanged: () {}');
    }
    
    if (node.properties['autovalidateMode'] != null) {
      props.add('autovalidateMode: AutovalidateMode.${node.properties['autovalidateMode']}');
    }
    
    final children = generateChildren(node.children, indent: indent);
    
    return '${indentStr}Form(${props.join(', ')}$children\n$indentStr)';
  }
} 