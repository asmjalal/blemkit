
import 'base_widget_generator.dart';
import '../models/widget_node.dart';

class ImageGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final rawUrl = node.properties['src']?.toString() ?? '';

    final named = <String>[];
    if (node.properties['width'] != null) {
      named.add('width: ${node.properties['width']}');
    }
    if (node.properties['height'] != null) {
      named.add('height: ${node.properties['height']}');
    }
    named.add('fit: BoxFit.cover');

    final String urlExpression;
    if (node.dataBinding != null && node.dataBinding!.containsKey('src')) {
      final binding = node.dataBinding!['src'] as Map;
      final field = binding['field'];
      urlExpression = queryFieldExpr(field);
    } else {
      urlExpression = "${dartString(rawUrl)}";
    }

    final namedStr = named.isEmpty ? '' : ', ${named.join(', ')}';
    return '${indentStr}Image.network($urlExpression$namedStr)';
  }
} 