import 'base_widget_generator.dart';
import '../models/widget_node.dart';

class CheckboxGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    
    final props = <String>[];
    props.add('value: false');
    props.add('onChanged: (value) {}');
    
    if (node.properties['activeColor'] != null) {
      props.add('activeColor: Color(${node.properties['activeColor']})');
    }
    
    return '${indentStr}Checkbox(${props.join(', ')})';
  }
} 