import '../base_widget_generator.dart';
import '../../models/widget_node.dart';

class TextFieldGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    if (node.properties['hintText'] != null || node.properties['labelText'] != null) {
      final decorationProps = <String>[];
      
      if (node.properties['hintText'] != null) {
        decorationProps.add("hintText: '${node.properties['hintText']}'");
      }
      if (node.properties['labelText'] != null) {
        decorationProps.add("labelText: '${node.properties['labelText']}'");
      }
      
      props.add('decoration: InputDecoration(${decorationProps.join(', ')})');
    }
    
    if (node.properties['onChanged'] != null) {
      props.add('onChanged: (value) {}');
    }
    
    if (node.properties['obscureText'] != null) {
      props.add('obscureText: ${node.properties['obscureText']}');
    }
    
    if (node.properties['keyboardType'] != null) {
      props.add('keyboardType: TextInputType.${node.properties['keyboardType']}');
    }
    
    return '${indentStr}TextField(${props.join(', ')})';
  }
}