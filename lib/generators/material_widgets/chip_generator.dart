import '../base_widget_generator.dart';
import '../project_generator.dart';
import '../../models/widget_node.dart';
import '../widget_generator_registry.dart';

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
      props.add('backgroundColor: ${formatColor(node.properties['backgroundColor'])}');
    }
    
    if (node.properties['radius'] != null) {
      props.add('radius: ${node.properties['radius']}');
    }
    
    if (node.children.isNotEmpty) {
      props.add('child: ${WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1).trimLeft()}');
    }
    
    final String? imgUrlExpression;
    if (node.dataBinding != null && node.dataBinding!.containsKey('url')) {
      final binding = node.dataBinding!['url'] as Map;
      final field = binding['field'];
      imgUrlExpression = ProjectGenerator.isInsideRepeatedList 
          ? "NetworkImage(item['$field']?.toString() ?? '')" 
          : "NetworkImage(data[0]['$field']?.toString() ?? '')";
    } else if (node.properties['backgroundImage'] != null && node.properties['backgroundImage'].toString().isNotEmpty) {
      imgUrlExpression = "NetworkImage('${escapeString(node.properties['backgroundImage'].toString())}')";
    } else {
      imgUrlExpression = null;
    }

    if (imgUrlExpression != null) {
      props.add('backgroundImage: $imgUrlExpression');
    }
    
    return '${indentStr}CircleAvatar(\n$childIndentStr ${props.join(',\n$childIndentStr ')}\n$indentStr)';
  }
}
 