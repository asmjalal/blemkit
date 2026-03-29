import 'base_widget_generator.dart';
import '../models/widget_node.dart';
import '../utils/property_converters.dart';
import 'widget_generator_registry.dart';

class ContainerGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    // Handle basic properties
    if (node.properties['width'] != null) props.add('width: ${node.properties['width']}');
    if (node.properties['height'] != null) props.add('height: ${node.properties['height']}');
    if (node.properties['alignment'] != null) {
      props.add('alignment: ${PropertyConverters.dartAlignment(node.properties['alignment'])}');
    }
    
    // Handle padding
    if (node.properties['padding'] != null) {
      final padding = node.properties['padding'];
      if (padding is Map) {
        final left = padding['left'] ?? 0;
        final right = padding['right'] ?? 0;
        final top = padding['top'] ?? 0;
        final bottom = padding['bottom'] ?? 0;
        props.add('padding: EdgeInsets.only(left: $left, top: $top, right: $right, bottom: $bottom)');
      } else {
        props.add('padding: EdgeInsets.all($padding)');
      }
    }
    
    // Handle margin
    if (node.properties['margin'] != null) {
      final margin = node.properties['margin'];
      if (margin is Map) {
        final left = margin['left'] ?? 0;
        final right = margin['right'] ?? 0;
        final top = margin['top'] ?? 0;
        final bottom = margin['bottom'] ?? 0;
        props.add('margin: EdgeInsets.only(left: $left, top: $top, right: $right, bottom: $bottom)');
      } else {
        props.add('margin: EdgeInsets.all($margin)');
      }
    }
    
    // Handle decoration (BoxDecoration)
    final Map<String, dynamic>? decorationMap = 
        node.properties['decoration'] is Map<String, dynamic>
            ? node.properties['decoration'] as Map<String, dynamic>
            : null;

    final decorationProps = <String>[];
    
    // Color: check top-level and decoration object
    final dynamic colorValue = node.properties['color'] ?? decorationMap?['color'];
    if (colorValue != null) {
      decorationProps.add('color: ${formatColor(colorValue)}');
    }
    
    // BorderRadius: check top-level and decoration object
    final dynamic borderRadiusValue = node.properties['borderRadius'] ?? decorationMap?['borderRadius'];
    if (borderRadiusValue != null) {
      decorationProps.add('borderRadius: BorderRadius.circular($borderRadiusValue)');
    }
    
    // Border
    final dynamic borderWidth = node.properties['borderWidth'] ?? decorationMap?['borderWidth'];
    if (borderWidth != null && borderWidth > 0) {
      final dynamic borderColor = node.properties['borderColor'] ?? decorationMap?['borderColor'] ?? '0xFF000000';
      decorationProps.add('border: Border.all(color: ${formatColor(borderColor)}, width: $borderWidth)');
    }
    
    // Shadow
    final dynamic shadowBlur = node.properties['shadowBlur'] ?? decorationMap?['shadowBlur'];
    if (shadowBlur != null && shadowBlur > 0) {
      final dynamic shadowColor = node.properties['shadowColor'] ?? decorationMap?['shadowColor'] ?? '0x42000000';
      final dynamic shadowX = node.properties['shadowX'] ?? decorationMap?['shadowX'] ?? 0.0;
      final dynamic shadowY = node.properties['shadowY'] ?? decorationMap?['shadowY'] ?? 0.0;
      decorationProps.add(
        'boxShadow: [BoxShadow(color: ${formatColor(shadowColor)}, blurRadius: $shadowBlur, '
        'offset: Offset($shadowX, $shadowY))]'
      );
    }
    
    if (decorationProps.isNotEmpty) {
      props.add('decoration: BoxDecoration(${decorationProps.join(', ')})');
    }
    
    // Handle child
    String child = '';
    if (node.children.isNotEmpty) {
      child = '\n$childIndentStr child: ${WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1)},';
    }
    
    return '${indentStr}Container(${props.isNotEmpty ? '\n$childIndentStr${props.join(',\n$childIndentStr')}${child.isNotEmpty ? ',' : ''}' : ''}$child\n$indentStr)';
  }
}
 