import 'base_widget_generator.dart';
import '../models/widget_node.dart';

class CircularProgressIndicatorGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final List<String> props = [];
    final color = node.properties['color'];
    if (color != null) {
      props.add('color: ${formatColor(color)}');
    }
    
    final strokeWidth = node.properties['strokeWidth'];
    if (strokeWidth != null) {
      props.add('strokeWidth: $strokeWidth');
    }
    
    final value = node.properties['value'];
    if (value != null) {
      props.add('value: $value');
    }

    final backgroundColor = node.properties['backgroundColor'];
    if (backgroundColor != null) {
      props.add('backgroundColor: ${formatColor(backgroundColor)}');
    }

    if (props.isEmpty) {
      return '${indentStr}CircularProgressIndicator()';
    }
    
    return '${indentStr}CircularProgressIndicator(\n'
        '${props.map((p) => "$childIndentStr$p,").join("\n")}\n'
        '$indentStr)';
  }
}
