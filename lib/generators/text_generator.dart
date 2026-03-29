import 'base_widget_generator.dart';
import '../models/widget_node.dart';
import '../utils/property_converters.dart';

class TextGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    
    final props = <String>[];
    
    // Handle text style
    if (_hasTextStyleProperties(node.properties)) {
      final styleProps = <String>[];
      
      if (node.properties['fontSize'] != null) {
        styleProps.add('fontSize: ${node.properties['fontSize']}');
      }
      if (node.properties['color'] != null) {
        styleProps.add('color: ${formatColor(node.properties['color'])}');
      }
      if (node.properties['decorationColor'] != null) {
        styleProps.add('decorationColor: ${formatColor(node.properties['decorationColor'])}');
      }
      if (node.properties['fontWeight'] != null && node.properties['fontWeight'] != 'normal') {
        styleProps.add('fontWeight: ${PropertyConverters.dartFontWeight(node.properties['fontWeight'])}');
      }
      if (node.properties['fontStyle'] == 'italic') {
        styleProps.add('fontStyle: FontStyle.italic');
      }
      if (node.properties['fontFamily'] != null) {
        styleProps.add("fontFamily: '${node.properties['fontFamily']}'");
      }
      if (node.properties['letterSpacing'] != null) {
        styleProps.add('letterSpacing: ${node.properties['letterSpacing']}');
      }
      if (node.properties['wordSpacing'] != null) {
        styleProps.add('wordSpacing: ${node.properties['wordSpacing']}');
      }
      if (node.properties['lineHeight'] != null) {
        styleProps.add('height: ${node.properties['lineHeight']}');
      }
      if (node.properties['textDecoration'] != null && node.properties['textDecoration'] != 'none') {
        styleProps.add('decoration: ${PropertyConverters.dartTextDecoration(node.properties['textDecoration'])}');
      }
      if (node.properties['shadowBlur'] != null && node.properties['shadowBlur'] > 0) {
        final shadowColor = node.properties['shadowColor'] ?? '0x42000000';
        styleProps.add(
          'shadows: [Shadow(color: ${formatColor(shadowColor)}, blurRadius: ${node.properties['shadowBlur']}, '
          'offset: Offset(${node.properties['shadowX'] ?? 0.0}, ${node.properties['shadowY'] ?? 0.0}))]'
        );
      }
      
      if (styleProps.isNotEmpty) {
        props.add('style: TextStyle(${styleProps.join(', ')})');
      }
    }
    
    // Handle other text properties
    if (node.properties['textAlign'] != null) {
      props.add('textAlign: ${PropertyConverters.dartTextAlign(node.properties['textAlign'])}');
    }
    if (node.properties['maxLines'] != null) {
      props.add('maxLines: ${(node.properties['maxLines'] as num).toInt()}');
    }
    if (node.properties['overflow'] != null) {
      props.add('overflow: ${PropertyConverters.dartTextOverflow(node.properties['overflow'])}');
    }
    if (node.properties['textDirection'] != null) {
      props.add('textDirection: ${node.properties['textDirection'] == 'rtl' ? 'TextDirection.rtl' : 'TextDirection.ltr'}');
    }
    if (node.properties['softWrap'] != null) {
      props.add('softWrap: ${node.properties['softWrap']}');
    }
    
    final childIndentStr = getChildIndentStr(indent);
    
    // Escape text content
    final textContent = escapeString(node.properties['text'] ?? 'Text');
    
    return props.isEmpty 
        ? '${indentStr}Text(\'$textContent\')'
        : '${indentStr}Text(\n$childIndentStr\'$textContent\',\n$childIndentStr${props.join(',\n$childIndentStr')}\n$indentStr)';

  }
  
  bool _hasTextStyleProperties(Map<String, dynamic> properties) {
    return properties['fontSize'] != null ||
           properties['color'] != null ||
           properties['fontWeight'] != null ||
           properties['fontStyle'] != null ||
           properties['fontFamily'] != null ||
           properties['letterSpacing'] != null ||
           properties['wordSpacing'] != null ||
           properties['lineHeight'] != null ||
           properties['textDecoration'] != null ||
           properties['shadowBlur'] != null;
  }
} 