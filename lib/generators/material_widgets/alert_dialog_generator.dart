import '../base_widget_generator.dart';
import '../widget_generator_registry.dart';
import '../../models/widget_node.dart';

class AlertDialogGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    if (node.properties['title'] != null) {
      props.add('title: Text(\'${node.properties['title']}\')');
    }
    
    if (node.properties['content'] != null) {
      props.add('content: Text(\'${node.properties['content']}\')');
    } else if (node.children.isNotEmpty) {
      props.add('content: ${WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1)}');
    }
    
    if (node.properties['actions'] != null) {
      props.add('actions: ${node.properties['actions']}');
    }
    
    if (node.properties['backgroundColor'] != null) {
      props.add('backgroundColor: Color(${node.properties['backgroundColor']})');
    }
    
    if (node.properties['elevation'] != null) {
      props.add('elevation: ${node.properties['elevation']}');
    }
    
    return '${indentStr}AlertDialog(${props.join(',\n$childIndentStr ')}\n$indentStr)';
  }
} 