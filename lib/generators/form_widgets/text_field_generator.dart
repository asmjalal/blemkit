import '../base_widget_generator.dart';
import '../../models/widget_node.dart';

class TextFieldGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final varName = '_controller_${node.id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
    final initialText = node.properties['text'] ?? '';
    
    BaseWidgetGenerator.stateVariables.add('late final TextEditingController $varName = TextEditingController(text: ${dartString(initialText)});');
    BaseWidgetGenerator.disposeVariables.add('$varName.dispose();');
    
    final props = <String>[];
    props.add('controller: $varName');
    
    if (node.properties['hintText'] != null || node.properties['labelText'] != null) {
      final decorationProps = <String>[];
      
      if (node.properties['hintText'] != null) {
        decorationProps.add("hintText: ${dartString(node.properties['hintText'])}");
      }
      if (node.properties['labelText'] != null) {
        decorationProps.add("labelText: ${dartString(node.properties['labelText'])}");
      }
      
      props.add('decoration: InputDecoration(${decorationProps.join(', ')})');
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