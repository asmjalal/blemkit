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
        props.add("title: Text(${dartString(title)})");
      } else if (title is WidgetNode) {
        props.add('title: ${WidgetGeneratorRegistry.generateCode(title, indent: 0)}');
      } else if (title is Map) {
        final titleNode = WidgetNode.fromJson(Map<String, dynamic>.from(title));
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
          if (action is WidgetNode) {
            return WidgetGeneratorRegistry.generateCode(action, indent: 0);
          } else if (action is Map) {
            final actionNode = WidgetNode.fromJson(Map<String, dynamic>.from(action));
            return WidgetGeneratorRegistry.generateCode(actionNode, indent: 0);
          }
          return 'Container()'; // fallback
        }).join(', ');
        props.add('actions: [$actionWidgets]');
      }
    }
    
    // Handle leading
    if (node.properties['leading'] != null) {
      final leading = node.properties['leading'];
      WidgetNode? leadingNode;
      if (leading is WidgetNode) {
        leadingNode = leading;
      } else if (leading is Map) {
        leadingNode = WidgetNode.fromJson(Map<String, dynamic>.from(leading));
      }
      if (leadingNode != null) {
        props.add('leading: ${WidgetGeneratorRegistry.generateCode(leadingNode, indent: 0)}');
      }
    }

    return props.isEmpty 
        ? '${indentStr}AppBar()'
        : '${indentStr}AppBar(\n$childIndentStr${props.join(',\n$childIndentStr')}\n$indentStr)';
  }
} 