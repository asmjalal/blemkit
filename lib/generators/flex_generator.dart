import 'base_widget_generator.dart';
import '../models/widget_node.dart';
import '../utils/property_converters.dart';
import 'widget_generator_registry.dart';

class FlexGenerator extends BaseWidgetGenerator {
  final bool isRow;

  FlexGenerator({this.isRow = true});

  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    if (node.properties['mainAxisAlignment'] != null) {
      props.add('mainAxisAlignment: ${PropertyConverters.dartMainAxisAlignment(node.properties['mainAxisAlignment'])}');
    }
    if (node.properties['crossAxisAlignment'] != null) {
      props.add('crossAxisAlignment: ${PropertyConverters.dartCrossAxisAlignment(node.properties['crossAxisAlignment'])}');
    }
    if (node.properties['mainAxisSize'] != null) {
      props.add('mainAxisSize: ${node.properties['mainAxisSize'] == 'min' ? 'MainAxisSize.min' : 'MainAxisSize.max'}');
    }
    if (node.properties['verticalDirection'] != null) {
      props.add('verticalDirection: ${node.properties['verticalDirection'] == 'up' ? 'VerticalDirection.up' : 'VerticalDirection.down'}');
    }
    if (node.properties['textDirection'] != null) {
      props.add('textDirection: ${node.properties['textDirection'] == 'rtl' ? 'TextDirection.rtl' : 'TextDirection.ltr'}');
    }
    
    final children = node.children.isNotEmpty 
        ? '\n$childIndentStr children: [\n${node.children.map((child) => '${getChildIndentStr(indent + 1)}${WidgetGeneratorRegistry.generateCode(child, indent: indent + 2)},').join('\n')}\n$childIndentStr],'
        : '';
    
    return '$indentStr${isRow ? 'Row' : 'Column'}(${props.isNotEmpty ? '\n$childIndentStr${props.join(',\n$childIndentStr')}${children.isNotEmpty ? ',' : ''}' : ''}$children\n$indentStr)';
  }
} 