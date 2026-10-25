import '../base_widget_generator.dart';
import '../widget_generator_registry.dart';
import '../../models/widget_node.dart';

class FormFieldGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    props.add('initialValue: ${dartString(node.properties['initialValue'] ?? '')}');
    props.add('validator: (value) => null');
    props.add('onSaved: (value) {}');
    
    if (node.properties['autovalidate'] != null) {
      props.add('autovalidate: ${node.properties['autovalidate']}');
    }
    
    String child = '';
    if (node.children.isNotEmpty) {
      child = '\n$childIndentStr builder: (FormFieldState state) => ${WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1)},';
    }
    
    return '${indentStr}FormField(${props.join(', ')}$child\n$indentStr)';
  }
} 