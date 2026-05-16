import 'base_widget_generator.dart';
import '../models/widget_node.dart';
import '../utils/property_converters.dart';

class SelectableTextGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final text = node.properties['text']?.toString() ?? 'Selectable Text';
    
    final props = <String>[];
    
    final textAlign = PropertyConverters.dartTextAlign(node.properties['textAlign']);
    if (textAlign != null) props.add('textAlign: $textAlign');
    
    final styleProps = <String>[];
    if (node.properties['color'] != null) {
      styleProps.add('color: ${formatColor(node.properties['color'])}');
    }
    
    final fontSize = node.properties['fontSize']?.toString();
    if (fontSize != null) styleProps.add('fontSize: $fontSize');
    
    final fontWeight = PropertyConverters.dartFontWeight(node.properties['fontWeight']);
    if (fontWeight != null) styleProps.add('fontWeight: $fontWeight');
    
    if (styleProps.isNotEmpty) {
      props.add('style: TextStyle(\n$childIndentStr  ${styleProps.join(',\n$childIndentStr  ')},\n$childIndentStr)');
    }
    
    final propsString = props.isNotEmpty ? ',\n$childIndentStr${props.join(',\n$childIndentStr')},' : '';

    return '''${indentStr}SelectableText(
$childIndentStr'$text'$propsString
$indentStr)''';
  }
}
