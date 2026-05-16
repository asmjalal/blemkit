import 'dart:convert';

import 'base_widget_generator.dart';
import '../models/widget_node.dart';

class ImageGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final rawUrl = node.properties['src']?.toString() ?? '';
    final urlLiteral = jsonEncode(rawUrl);

    final named = <String>[];
    if (node.properties['width'] != null) {
      named.add('width: ${node.properties['width']}');
    }
    if (node.properties['height'] != null) {
      named.add('height: ${node.properties['height']}');
    }
    named.add('fit: BoxFit.cover');

    final namedStr = named.isEmpty ? '' : ', ${named.join(', ')}';
    return '${indentStr}Image.network($urlLiteral$namedStr)';
  }
} 