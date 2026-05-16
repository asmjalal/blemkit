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
      props.add('padding: const ${parseEdgeInsets(node.properties['padding'])}');
    }
    
    // Handle margin
    if (node.properties['margin'] != null) {
      props.add('margin: const ${parseEdgeInsets(node.properties['margin'])}');
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

    // Gradient
    final dynamic gradientValue = node.properties['gradient'] ?? decorationMap?['gradient'];
    if (gradientValue is Map<String, dynamic>) {
      final List<dynamic> colors = gradientValue['colors'] ?? [];
      final String begin = gradientValue['begin'] ?? 'Alignment.centerLeft';
      final String end = gradientValue['end'] ?? 'Alignment.centerRight';
      final formattedColors = colors.map((c) => formatColor(c)).join(', ');
      decorationProps.add('gradient: LinearGradient(begin: $begin, end: $end, colors: [$formattedColors])');
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
 