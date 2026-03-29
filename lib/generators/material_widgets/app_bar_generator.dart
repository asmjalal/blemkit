import '../base_widget_generator.dart';
import '../../models/widget_node.dart';
import '../widget_generator_registry.dart';

class AppBarGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    // Handle title
    if (node.properties['title'] != null) {
      final title = node.properties['title'];
      if (title is String) {
        props.add('title: Text(\'$title\')');
      } else if (title is Map<String, dynamic>) {
        final titleNode = WidgetNode.fromJson(title);
        props.add('title: ${WidgetGeneratorRegistry.generateCode(titleNode, indent: 0)}');
      }
    }
    
    // Handle backgroundColor
    if (node.properties['backgroundColor'] != null) {
      props.add('backgroundColor: ${formatColor(node.properties['backgroundColor'])}');
    }
    
    // Handle elevation
    if (node.properties['elevation'] != null) {
      props.add('elevation: ${node.properties['elevation']}');
    }
    
    // Handle centerTitle
    if (node.properties['centerTitle'] != null) {
      props.add('centerTitle: ${node.properties['centerTitle']}');
    }
    
    // Handle actions
    if (node.properties['actions'] != null && node.properties['actions'] is List) {
      final actions = node.properties['actions'] as List;
      if (actions.isNotEmpty) {
        final actionWidgets = actions.map((action) {
          if (action is Map<String, dynamic>) {
            final actionNode = WidgetNode.fromJson(action);
            return WidgetGeneratorRegistry.generateCode(actionNode, indent: 0);
          }
          return 'Container()'; // fallback
        }).join(', ');
        props.add('actions: [$actionWidgets]');
      }
    }
    
    // Handle leading
    if (node.properties['leading'] != null && node.properties['leading'] is Map) {
      final leadingNode = WidgetNode.fromJson(node.properties['leading']);
      props.add('leading: ${WidgetGeneratorRegistry.generateCode(leadingNode, indent: 0)}');
    }

    return props.isEmpty 
        ? '${indentStr}AppBar()'
        : '${indentStr}AppBar(\n$childIndentStr${props.join(',\n$childIndentStr')}\n$indentStr)';
  }
} 