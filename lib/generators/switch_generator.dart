import 'base_widget_generator.dart';
import '../models/widget_node.dart';

class SwitchGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    
    final props = <String>[];
    props.add('value: false');
    props.add('onChanged: (value) {}');
    
    if (node.properties['activeColor'] != null) {
      props.add('activeColor: Color(${node.properties['activeColor']})');
    }
    if (node.properties['activeTrackColor'] != null) {
      props.add('activeTrackColor: Color(${node.properties['activeTrackColor']})');
    }
    
    return '${indentStr}Switch(${props.join(', ')})';
  }
}