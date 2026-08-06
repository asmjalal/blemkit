import 'base_widget_generator.dart';
import '../models/widget_node.dart';

class LinearProgressIndicatorGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final List<String> props = [];
    final color = node.properties['color'];
    if (color != null) {
      props.add('color: ${formatColor(color)}');
    }
    
    final value = node.properties['value'];
    if (value != null) {
      props.add('value: $value');
    }

    final backgroundColor = node.properties['backgroundColor'];
    if (backgroundColor != null) {
      props.add('backgroundColor: ${formatColor(backgroundColor)}');
    }

    final minHeight = node.properties['minHeight'];
    if (minHeight != null) {
      props.add('minHeight: $minHeight');
    }

    if (props.isEmpty) {
      return '${indentStr}LinearProgressIndicator()';
    }
    
    return '${indentStr}LinearProgressIndicator(\n'
        '${props.map((p) => "$childIndentStr$p,").join("\n")}\n'
        '$indentStr)';
  }
}
