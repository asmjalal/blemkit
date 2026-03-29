import 'base_widget_generator.dart';
import '../models/widget_node.dart';

class RadioGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    
    final props = <String>[];
    props.add('value: \'${node.properties['value'] ?? 'option1'}\'');
    props.add('groupValue: \'option1\'');
    props.add('onChanged: (value) {}');
    
    if (node.properties['activeColor'] != null) {
      props.add('activeColor: Color(${node.properties['activeColor']})');
    }
    
    return '${indentStr}Radio(${props.join(', ')})';
  }
} 