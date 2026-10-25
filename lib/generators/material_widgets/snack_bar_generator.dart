import '../base_widget_generator.dart';
import '../../models/widget_node.dart';

class SnackBarGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    if (node.properties['content'] != null) {
      props.add('content: Text(${dartString(node.properties['content'])})');
    }
    
    if (node.properties['backgroundColor'] != null) {
      props.add('backgroundColor: Color(${node.properties['backgroundColor']})');
    }
    
    if (node.properties['duration'] != null) {
      props.add('duration: Duration(milliseconds: ${node.properties['duration']})');
    }
    
    if (node.properties['action'] != null) {
      props.add('action: ${node.properties['action']}');
    }
    
    if (node.properties['behavior'] != null) {
      props.add('behavior: SnackBarBehavior.${node.properties['behavior']}');
    }
    
    return '${indentStr}SnackBar(${props.join(',\n$childIndentStr ')}\n$indentStr)';
  }
} 