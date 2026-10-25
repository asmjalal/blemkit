import 'base_widget_generator.dart';
import '../models/widget_node.dart';

class RadioGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final groupVar = '_radioGroup_${node.id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
    final value = node.properties['value'] ?? 'option1';
    
    // Register group value state if not already present (simplified for now)
    BaseWidgetGenerator.stateVariables.add('dynamic $groupVar = ${dartString(value)};');
    
    final props = <String>[];
    props.add('value: ${dartString(value)}');
    props.add('groupValue: $groupVar');
    props.add('onChanged: (value) => setState(() => $groupVar = value!)');
    
    if (node.properties['activeColor'] != null) {
      props.add('activeColor: ${formatColor(node.properties['activeColor'])}');
    }
    
    return '${indentStr}Radio(${props.join(', ')})';
  }
}