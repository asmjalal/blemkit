import '../../models/widget_node.dart';
import 'base_widget_generator.dart';

class RangeSliderGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = '  ' * indent;
    final childIndent = '  ' * (indent + 1);
    
    final min = (node.properties['min'] as num?)?.toDouble() ?? 0.0;
    final max = (node.properties['max'] as num?)?.toDouble() ?? 100.0;
    final startValue = (node.properties['startValue'] as num?)?.toDouble() ?? (min + (max - min) * 0.25);
    final endValue = (node.properties['endValue'] as num?)?.toDouble() ?? (min + (max - min) * 0.75);
    final divisions = node.properties['divisions'] as int?;

    String code = '${indentStr}RangeSlider(\n'
        '${childIndent}values: const RangeValues($startValue, $endValue),\n'
        '${childIndent}min: $min,\n'
        '${childIndent}max: $max,\n';
        
    if (divisions != null) {
      code += '${childIndent}divisions: $divisions,\n'
              '${childIndent}labels: const RangeLabels(\'$startValue\', \'$endValue\'),\n';
    }
    
    code += '${childIndent}onChanged: (RangeValues values) {\n'
            '${childIndent}  // Add logic to handle range slider change\n'
            '${childIndent}},\n'
            '$indentStr),\n';
            
    return code;
  }
}
