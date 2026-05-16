import '../base_widget_generator.dart';
import '../../models/widget_node.dart';

class CheckboxListTileGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final varName = '_checkbox_${node.id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
    BaseWidgetGenerator.stateVariables.add('bool $varName = ${node.properties['value'] ?? false};');
    
    final props = <String>[];
    props.add('title: Text(\'${node.properties['title'] ?? 'Checkbox List Tile'}\')');
    props.add('value: $varName');
    props.add('onChanged: (value) => setState(() => $varName = value!)');
    
    if (node.properties['subtitle'] != null) {
      props.add('subtitle: Text(\'${node.properties['subtitle']}\')');
    }
    
    if (node.properties['activeColor'] != null) {
      props.add('activeColor: ${formatColor(node.properties['activeColor'])}');
    }
    
    if (node.properties['checkColor'] != null) {
      props.add('checkColor: ${formatColor(node.properties['checkColor'])}');
    }
    
    return '${indentStr}CheckboxListTile(${props.join(', ')})';
  }
} 