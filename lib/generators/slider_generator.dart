import 'base_widget_generator.dart';
import '../models/widget_node.dart';

class SliderGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    
    final props = <String>[];
    props.add('value: ${node.properties['value'] ?? 0.0}');
    props.add('min: ${node.properties['min'] ?? 0.0}');
    props.add('max: ${node.properties['max'] ?? 100.0}');
    props.add('onChanged: (value) {}');
    
    if (node.properties['activeColor'] != null) {
      props.add('activeColor: Color(${node.properties['activeColor']})');
    }
    if (node.properties['inactiveColor'] != null) {
      props.add('inactiveColor: Color(${node.properties['inactiveColor']})');
    }
    
    return '${indentStr}Slider(${props.join(', ')})';
  }
} 