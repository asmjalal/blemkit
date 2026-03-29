import '../base_widget_generator.dart';
import '../../models/widget_node.dart';

class SwitchListTileGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    props.add('title: Text(\'${node.properties['title'] ?? 'Switch List Tile'}\')');
    props.add('value: false');
    props.add('onChanged: (value) {}');
    
    if (node.properties['subtitle'] != null) {
      props.add('subtitle: Text(\'${node.properties['subtitle']}\')');
    }
    
    if (node.properties['activeColor'] != null) {
      props.add('activeColor: Color(${node.properties['activeColor']})');
    }
    
    if (node.properties['activeTrackColor'] != null) {
      props.add('activeTrackColor: Color(${node.properties['activeTrackColor']})');
    }
    
    return '${indentStr}SwitchListTile(${props.join(', ')})';
  }
} 