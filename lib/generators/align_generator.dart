import 'base_widget_generator.dart';
import 'widget_generator_registry.dart';
import '../models/widget_node.dart';
import '../utils/property_converters.dart';

class AlignGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    if (node.properties['alignment'] != null) {
      props.add('alignment: ${PropertyConverters.dartAlignment(node.properties['alignment'])}');
    } else {
      props.add('alignment: Alignment.center');
    }
    
    String child = '';
    if (node.children.isNotEmpty) {
      child = '\n$childIndentStr child: ${WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1)},';
    }
    
    return '${indentStr}Align(${props.join(', ')}$child\n$indentStr)';
  }
} 