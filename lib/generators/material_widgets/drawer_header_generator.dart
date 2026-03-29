import '../base_widget_generator.dart';
import '../../models/widget_node.dart';
import '../widget_generator_registry.dart';

class DrawerHeaderGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);

    final props = <String>[];

    // Handle decoration
    if (node.properties['decoration'] is Map<String, dynamic>) {
      final decorationProps = <String>[];
      final decorationMap = node.properties['decoration'] as Map<String, dynamic>;

      if (decorationMap['color'] != null) {
        decorationProps.add('color: Color(${decorationMap['color']})');
      }
      // Add other BoxDecoration properties as needed

      if (decorationProps.isNotEmpty) {
        props.add('decoration: BoxDecoration(${decorationProps.join(', ')})');
      }
    }

    // Handle child
    if (node.properties['child'] is Map<String, dynamic>) {
      try {
        final WidgetNode childNode = WidgetNode.fromJson(node.properties['child']);
        props.add('child: ${WidgetGeneratorRegistry.generateCode(childNode, indent: indent + 1)}');
      } catch (e) {
        print('Error generating DrawerHeader child code: $e');
      }
    } else if (node.children.isNotEmpty) {
      // Fallback to direct children if child property is not a map
      props.add('child: ${WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1)}');
    }

    // Add other properties of DrawerHeader like padding, margin etc.
    if (node.properties['padding'] != null) {
      props.add('padding: ${node.properties['padding']}');
    }

    return '${indentStr}DrawerHeader(${props.join(',\n$childIndentStr ')}\n$indentStr)';
  }
} 