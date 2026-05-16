import 'base_widget_generator.dart';
import '../models/widget_node.dart';
import '../utils/property_converters.dart';

class VerticalDividerGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final width = node.properties['width']?.toString();
    final thickness = node.properties['thickness']?.toString();
    final indentVal = node.properties['indent']?.toString();
    final endIndent = node.properties['endIndent']?.toString();

    final props = <String>[];
    if (width != null) props.add('width: $width');
    if (thickness != null) props.add('thickness: $thickness');
    if (indentVal != null) props.add('indent: $indentVal');
    if (endIndent != null) props.add('endIndent: $endIndent');
    if (node.properties['color'] != null) {
      props.add('color: ${formatColor(node.properties['color'])}');
    }

    if (props.isEmpty) {
      return '${indentStr}const VerticalDivider()';
    }

    return '''${indentStr}VerticalDivider(
${childIndentStr}${props.join(',\n$childIndentStr')},
$indentStr)''';
  }
}
