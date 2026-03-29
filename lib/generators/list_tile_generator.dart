import 'package:designflutterkit/generators/widget_generator_registry.dart';

import '../../models/widget_node.dart';
import 'base_widget_generator.dart';

class ListTileGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndent = getIndentString(indent + 1);

    final props = <String>[];

    // title: String → wrap in Text(), Map → generate as widget
    final title = node.properties['title'];
    if (title != null) {
      if (title is String) {
        props.add("${childIndent}title: Text('$title')");
      } else if (title is Map<String, dynamic>) {
        final titleNode = WidgetNode.fromJson(title);
        props.add('${childIndent}title: ${WidgetGeneratorRegistry.generateCode(titleNode, indent: indent + 1)}');
      }
    }

    // subtitle: String → wrap in Text(), Map → generate as widget
    final subtitle = node.properties['subtitle'];
    if (subtitle != null) {
      if (subtitle is String) {
        props.add("${childIndent}subtitle: Text('$subtitle')");
      } else if (subtitle is Map<String, dynamic>) {
        final subtitleNode = WidgetNode.fromJson(subtitle);
        props.add('${childIndent}subtitle: ${WidgetGeneratorRegistry.generateCode(subtitleNode, indent: indent + 1)}');
      }
    }

    // leading: String (icon name) → Icon(...), Map → generate as widget
    final leading = node.properties['leading'];
    if (leading != null) {
      if (leading is String && leading.startsWith('Icons.')) {
        props.add('${childIndent}leading: Icon($leading)');
      } else if (leading is Map<String, dynamic>) {
        final leadingNode = WidgetNode.fromJson(leading);
        props.add('${childIndent}leading: ${WidgetGeneratorRegistry.generateCode(leadingNode, indent: indent + 1)}');
      }
    }

    // trailing: String (icon name) → Icon(...), Map → generate as widget
    final trailing = node.properties['trailing'];
    if (trailing != null) {
      if (trailing is String && trailing.startsWith('Icons.')) {
        props.add('${childIndent}trailing: Icon($trailing)');
      } else if (trailing is Map<String, dynamic>) {
        final trailingNode = WidgetNode.fromJson(trailing);
        props.add('${childIndent}trailing: ${WidgetGeneratorRegistry.generateCode(trailingNode, indent: indent + 1)}');
      }
    }

    // selected / tileColor
    if (node.properties.containsKey('selected')) {
      props.add('${childIndent}selected: ${node.properties['selected']}');
    }
    if (node.properties.containsKey('tileColor') && node.properties['tileColor'] != null) {
      props.add('${childIndent}tileColor: ${formatColor(node.properties['tileColor'])}');
    }

    // onTap
    props.add('${childIndent}onTap: () {}');

    return '${indentStr}ListTile(\n${props.join(',\n')},\n$indentStr)';
  }
}