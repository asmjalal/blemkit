import 'base_widget_generator.dart';
import '../models/widget_node.dart';
import '../utils/property_converters.dart';

class StackGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    if (node.properties['alignment'] != null) {
      props.add('alignment: ${PropertyConverters.dartAlignment(node.properties['alignment'])}');
    }
    if (node.properties['fit'] != null) {
      props.add('fit: StackFit.${node.properties['fit']}');
    }
    
    final children = generateChildren(node.children, indent: indent);
    
    return '${indentStr}Stack(${props.isEmpty ? '' : '${props.join(', ')},'}$children\n$indentStr)';
  }
} 