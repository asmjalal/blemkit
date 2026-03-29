import '../base_widget_generator.dart';
import '../../models/widget_node.dart';

class BottomSheetGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    if (node.properties['backgroundColor'] != null) {
      props.add('backgroundColor: Color(${node.properties['backgroundColor']})');
    }
    
    if (node.properties['elevation'] != null) {
      props.add('elevation: ${node.properties['elevation']}');
    }
    
    if (node.properties['shape'] != null) {
      props.add('shape: ${node.properties['shape']}');
    }
    
    if (node.properties['enableDrag'] != null) {
      props.add('enableDrag: ${node.properties['enableDrag']}');
    }
    
    final child = node.children.isNotEmpty 
        ? generateCode(node.children.first, indent: indent + 1)
        : 'Container()';
    
    props.add('child: $child');
    
    return '${indentStr}BottomSheet(${props.join(',\n$childIndentStr ')}\n$indentStr)';
  }
} 