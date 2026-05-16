import 'base_widget_generator.dart';
import '../models/widget_node.dart';

class SliderGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final varName = '_slider_${node.id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
    BaseWidgetGenerator.stateVariables.add('double $varName = ${node.properties['value'] ?? 0.0};');
    
    final props = <String>[];
    props.add('value: $varName');
    props.add('min: ${node.properties['min'] ?? 0.0}');
    props.add('max: ${node.properties['max'] ?? 100.0}');
    props.add('onChanged: (value) => setState(() => $varName = value)');
    
    if (node.properties['activeColor'] != null) {
      props.add('activeColor: ${formatColor(node.properties['activeColor'])}');
    }
    if (node.properties['inactiveColor'] != null) {
      props.add('inactiveColor: ${formatColor(node.properties['inactiveColor'])}');
    }
    
    return '${indentStr}Slider(${props.join(', ')})';
  }
}