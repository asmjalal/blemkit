import '../base_widget_generator.dart';
import '../../models/widget_node.dart';

class CheckboxListTileGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    props.add('title: Text(\'${node.properties['title'] ?? 'Checkbox List Tile'}\')');
    props.add('value: false');
    props.add('onChanged: (value) {}');
    
    if (node.properties['subtitle'] != null) {
      props.add('subtitle: Text(\'${node.properties['subtitle']}\')');
    }
    
    if (node.properties['activeColor'] != null) {
      props.add('activeColor: Color(${node.properties['activeColor']})');
    }
    
    if (node.properties['checkColor'] != null) {
      props.add('checkColor: Color(${node.properties['checkColor']})');
    }
    
    return '${indentStr}CheckboxListTile(${props.join(', ')})';
  }
} 