import 'base_widget_generator.dart';
import '../models/widget_node.dart';

class SwitchGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final varName = '_switch_${node.id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
    BaseWidgetGenerator.stateVariables.add('bool $varName = ${node.properties['value'] ?? false};');
    
    final props = <String>[];
    props.add('value: $varName');
    props.add('onChanged: (value) => setState(() => $varName = value!)');
    
    if (node.properties['activeColor'] != null) {
      props.add('activeColor: ${formatColor(node.properties['activeColor'])}');
    }
    if (node.properties['activeTrackColor'] != null) {
      props.add('activeTrackColor: ${formatColor(node.properties['activeTrackColor'])}');
    }
    
    return '${indentStr}Switch(${props.join(', ')})';
  }
}