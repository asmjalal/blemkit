import '../base_widget_generator.dart';
import '../../models/widget_node.dart';

class RadioListTileGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    props.add('title: Text(\'${node.properties['title'] ?? 'Radio List Tile'}\')');
    props.add('value: \'${node.properties['value'] ?? 'option1'}\'');
    props.add('groupValue: \'option1\'');
    props.add('onChanged: (value) {}');
    
    if (node.properties['subtitle'] != null) {
      props.add('subtitle: Text(\'${node.properties['subtitle']}\')');
    }
    
    if (node.properties['activeColor'] != null) {
      props.add('activeColor: Color(${node.properties['activeColor']})');
    }
    
    return '${indentStr}RadioListTile(${props.join(', ')})';
  }
} 