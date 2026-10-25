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
    final titleBinding = node.dataBinding?['title'];
    if (titleBinding != null) {
      final field = titleBinding['field'];
      final textExpression = queryFieldExpr(field);
      props.add("${childIndent}title: Text($textExpression)");
    } else {
      final title = node.properties['title'];
      if (title != null) {
        if (title is String) {
          props.add("${childIndent}title: Text(${dartString(title)})");
        } else if (title is WidgetNode) {
          props.add('${childIndent}title: ${WidgetGeneratorRegistry.generateCode(title, indent: indent + 1)}');
        } else if (title is Map) {
          final titleNode = WidgetNode.fromJson(Map<String, dynamic>.from(title));
          props.add('${childIndent}title: ${WidgetGeneratorRegistry.generateCode(titleNode, indent: indent + 1)}');
        }
      }
    }

    // subtitle: String → wrap in Text(), Map → generate as widget
    final subtitleBinding = node.dataBinding?['subtitle'];
    if (subtitleBinding != null) {
      final field = subtitleBinding['field'];
      final textExpression = queryFieldExpr(field);
      props.add("${childIndent}subtitle: Text($textExpression)");
    } else {
      final subtitle = node.properties['subtitle'];
      if (subtitle != null) {
        if (subtitle is String) {
          props.add("${childIndent}subtitle: Text(${dartString(subtitle)})");
        } else if (subtitle is WidgetNode) {
          props.add('${childIndent}subtitle: ${WidgetGeneratorRegistry.generateCode(subtitle, indent: indent + 1)}');
        } else if (subtitle is Map) {
          final subtitleNode = WidgetNode.fromJson(Map<String, dynamic>.from(subtitle));
          props.add('${childIndent}subtitle: ${WidgetGeneratorRegistry.generateCode(subtitleNode, indent: indent + 1)}');
        }
      }
    }

    // leading
    final leadingIconStr = node.properties['leadingIcon'];
    final leadingIconColor = node.properties['leadingIconColor'];
    final leading = node.properties['leading'];
    
    if (leadingIconStr != null && leadingIconStr.toString().trim().isNotEmpty) {
      String iconName = leadingIconStr.toString().trim();
      if (!iconName.startsWith('Icons.') && !iconName.startsWith('FontAwesomeIcons.')) {
        iconName = 'Icons.$iconName';
      }
      final colorStr = leadingIconColor != null ? ', color: Color($leadingIconColor)' : '';
      props.add('${childIndent}leading: Icon($iconName$colorStr)');
    } else if (leading != null) {
      if (leading is String && (leading.startsWith('Icons.') || leading.startsWith('FontAwesomeIcons.'))) {
        props.add('${childIndent}leading: Icon($leading)');
      } else if (leading is WidgetNode) {
        props.add('${childIndent}leading: ${WidgetGeneratorRegistry.generateCode(leading, indent: indent + 1)}');
      } else if (leading is Map) {
        final leadingNode = WidgetNode.fromJson(Map<String, dynamic>.from(leading));
        props.add('${childIndent}leading: ${WidgetGeneratorRegistry.generateCode(leadingNode, indent: indent + 1)}');
      }
    }

    // trailing
    final trailingIconStr = node.properties['trailingIcon'];
    final trailingIconColor = node.properties['trailingIconColor'];
    final trailing = node.properties['trailing'];
    
    if (trailingIconStr != null && trailingIconStr.toString().trim().isNotEmpty) {
      String iconName = trailingIconStr.toString().trim();
      if (!iconName.startsWith('Icons.') && !iconName.startsWith('FontAwesomeIcons.')) {
        iconName = 'Icons.$iconName';
      }
      final colorStr = trailingIconColor != null ? ', color: Color($trailingIconColor)' : '';
      final trailingNavigateTo = node.properties['trailingNavigateTo'];
      if (trailingNavigateTo != null) {
        final navCode = generateNavigationCode(trailingNavigateTo);
        props.add('${childIndent}trailing: IconButton(icon: Icon($iconName$colorStr), onPressed: $navCode)');
      } else {
        props.add('${childIndent}trailing: Icon($iconName$colorStr)');
      }
    } else if (trailing != null) {
      if (trailing is String && (trailing.startsWith('Icons.') || trailing.startsWith('FontAwesomeIcons.'))) {
        props.add('${childIndent}trailing: Icon($trailing)');
      } else if (trailing is WidgetNode) {
        props.add('${childIndent}trailing: ${WidgetGeneratorRegistry.generateCode(trailing, indent: indent + 1)}');
      } else if (trailing is Map) {
        final trailingNode = WidgetNode.fromJson(Map<String, dynamic>.from(trailing));
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
    final actions = node.properties['actions'];
    final fallbackNavigateTo = node.properties['navigateTo'];
    props.add('${childIndent}onTap: ${generateActionFlowCode(actions, fallbackNavigateTo)}');

    return '${indentStr}ListTile(\n${props.join(',\n')},\n$indentStr)';
  }
}