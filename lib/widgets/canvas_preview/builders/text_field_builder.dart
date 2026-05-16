import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class TextFieldBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return TextField(
      decoration: InputDecoration(
        hintText: node.properties['hintText'] as String? ?? 'Enter text',
        labelText: node.properties['labelText'] as String?,
        border: _parseBorder(node.properties['border']),
        filled: node.properties['filled'] ?? false,
        fillColor: parseColor(node.properties['fillColor'], context),
        prefixIcon: _parseIcon(node.properties['prefixIcon'], context, hoveredNode),
        suffixIcon: _parseIcon(node.properties['suffixIcon'], context, hoveredNode),
        contentPadding: parseEdgeInsets(node.properties['contentPadding']),
      ),
      style: TextStyle(
        fontSize: parseDouble(node.properties['fontSize']) ?? 16.0,
        color: parseColor(node.properties['color'], context),
        fontWeight: parseFontWeight(node.properties['fontWeight']),
        fontFamily: node.properties['fontFamily'] as String?,
      ),
      maxLines: node.properties['maxLines'] as int? ?? 1,
      obscureText: node.properties['obscureText'] ?? false,
      enabled: node.properties['enabled'] ?? true,
      readOnly: node.properties['readOnly'] ?? false,
      keyboardType: _parseKeyboardType(node.properties['keyboardType']),
      textAlign: parseTextAlign(node.properties['textAlign']) ?? TextAlign.start,
      onChanged: (value) {},
      onSubmitted: (value) {},
    );
  }

  InputBorder? _parseBorder(dynamic value) {
    if (value == null) return null;
    
    switch (value) {
      case 'OutlineInputBorder':
        return const OutlineInputBorder();
      case 'UnderlineInputBorder':
        return const UnderlineInputBorder();
      case 'none':
        return InputBorder.none;
      default:
        return null;
    }
  }

  Widget? _parseIcon(dynamic value, BuildContext context, WidgetNode? hoveredNode) {
    if (value == null) return null;

    if (value is WidgetNode || value is Map<String, dynamic>) {
      return safeWidget(context, value, hoveredNode);
    }

    if (value is String) {
      final iconData = parseIconData(value);
      if (value.startsWith('FontAwesomeIcons.')) {
        return FaIcon(iconData);
      }
      return Icon(iconData as IconData? ?? Icons.widgets);
    }

    return null;
  }

  TextInputType? _parseKeyboardType(dynamic value) {
    if (value == null) return null;
    
    switch (value) {
      case 'text':
        return TextInputType.text;
      case 'number':
        return TextInputType.number;
      case 'email':
        return TextInputType.emailAddress;
      case 'phone':
        return TextInputType.phone;
      case 'url':
        return TextInputType.url;
      case 'multiline':
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }
}
