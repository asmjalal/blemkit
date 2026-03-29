import 'base_widget_generator.dart';
import '../models/widget_node.dart';

class DropdownButtonGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    props.add('value: \'${node.properties['value'] ?? 'Option 1'}\'');
    props.add('items: [\n$childIndentStr DropdownMenuItem(value: \'Option 1\', child: Text(\'Option 1\')),\n$childIndentStr DropdownMenuItem(value: \'Option 2\', child: Text(\'Option 2\')),\n$indentStr]');
    props.add('onChanged: (value) {}');
    
    if (node.properties['hint'] != null) {
      props.add('hint: Text(\'${node.properties['hint']}\')');
    }
    
    return '${indentStr}DropdownButton(${props.join(',\n$childIndentStr ')}\n$indentStr)';
  }
}