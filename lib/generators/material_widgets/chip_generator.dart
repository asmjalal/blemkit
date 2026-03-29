import '../base_widget_generator.dart';
import '../../models/widget_node.dart';

class ChipGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    if (node.properties['label'] != null) {
      props.add('label: Text(\'${node.properties['label']}\')');
    }
    
    if (node.properties['avatar'] != null) {
      props.add('avatar: ${node.properties['avatar']}');
    }
    
    if (node.properties['backgroundColor'] != null) {
      props.add('backgroundColor: Color(${node.properties['backgroundColor']})');
    }
    
    if (node.properties['deleteIcon'] != null) {
      props.add('deleteIcon: ${node.properties['deleteIcon']}');
    }
    
    if (node.properties['onDeleted'] != null) {
      props.add('onDeleted: ${node.properties['onDeleted']}');
    }
    
    return '${indentStr}Chip(${props.join(',\n$childIndentStr ')}\n$indentStr)';
  }
}

class CircleAvatarGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    if (node.properties['backgroundColor'] != null) {
      props.add('backgroundColor: Color(${node.properties['backgroundColor']})');
    }
    
    if (node.properties['radius'] != null) {
      props.add('radius: ${node.properties['radius']}');
    }
    
    if (node.properties['child'] != null) {
      props.add('child: ${node.properties['child']}');
    } else if (node.children.isNotEmpty) {
      props.add('child: ${generateCode(node.children.first, indent: indent + 1)}');
    }
    
    if (node.properties['backgroundImage'] != null) {
      props.add('backgroundImage: NetworkImage(\'${node.properties['backgroundImage']}\')');
    }
    
    return '${indentStr}CircleAvatar(${props.join(',\n$childIndentStr ')}\n$indentStr)';
  }
} 