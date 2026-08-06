import 'base_widget_generator.dart';
import '../models/widget_node.dart';
import 'widget_generator_registry.dart';

class MaterialButtonGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    final actions = node.properties['actions'] as List<dynamic>?;
    final fallbackNavigateTo = node.properties['navigateTo'];
    if (actions != null || fallbackNavigateTo != null || node.properties['onPressed'] != null) {
      props.add('onPressed: ${generateActionFlowCode(actions, fallbackNavigateTo)}');
    } else {
      props.add('onPressed: () {}');
    }
    
    if (node.properties['color'] != null) {
      props.add('color: ${formatColor(node.properties['color'])}');
    }
    if (node.properties['textColor'] != null) {
      props.add('textColor: ${formatColor(node.properties['textColor'])}');
    }
    if (node.properties['disabledColor'] != null) {
      props.add('disabledColor: ${formatColor(node.properties['disabledColor'])}');
    }
    if (node.properties['splashColor'] != null) {
      props.add('splashColor: ${formatColor(node.properties['splashColor'])}');
    }
    if (node.properties['highlightColor'] != null) {
      props.add('highlightColor: ${formatColor(node.properties['highlightColor'])}');
    }
    
    if (node.properties['padding'] != null) {
      final padding = node.properties['padding'];
      if (padding is num) {
        props.add('padding: const EdgeInsets.all(${padding.toDouble()})');
      } else if (padding is String) {
        props.add('padding: const $padding');
      } else if (padding is Map) {
        final left = padding['left'] ?? 0.0;
        final top = padding['top'] ?? 0.0;
        final right = padding['right'] ?? 0.0;
        final bottom = padding['bottom'] ?? 0.0;
        props.add('padding: const EdgeInsets.only(left: $left, top: $top, right: $right, bottom: $bottom)');
      }
    }
    
    if (node.properties['elevation'] != null) {
      props.add('elevation: ${node.properties['elevation']}');
    }
    if (node.properties['minWidth'] != null) {
      props.add('minWidth: ${node.properties['minWidth']}');
    }
    if (node.properties['height'] != null) {
      props.add('height: ${node.properties['height']}');
    }
    
    if (node.properties['borderRadius'] != null) {
      final br = node.properties['borderRadius'];
      props.add('shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular($br))');
    }
    
    String child = '';
    if (node.children.isNotEmpty) {
      child = '\n$childIndentStr child: ${WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1)},';
    } else if (node.properties['text'] != null) {
      final textContent = node.properties['text'].toString().replaceAll('\$', '\\\$');
      child = '\n$childIndentStr child: Text(\'$textContent\'),';
    } else {
      child = '\n$childIndentStr child: const Text(\'Material Button\'),';
    }
    
    return '${indentStr}MaterialButton(\n$childIndentStr${props.join(',\n$childIndentStr')}$child\n$indentStr)';
  }
}
